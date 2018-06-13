require 'json'

module PTT
  # Consumer processes incoming messages. It supports auto-retry mechanism
  # for cases when related handler fails to process a message.
  #
  # The auto-retry is based on [dead-lettering functionality provided by
  # RabbitMQ](https://www.rabbitmq.com/dlx.html). When a call to handler fails
  # and retry is possible (see below), the message is published to
  # the special retry queue with a specific TTL. When the message in the retry
  # queue is expired (dead-lettered), RabbitMQ automatically publishes it
  # to the work queue again.
  #
  #                       work.queue.retry     retry-exchange
  #                       ┌─┬─┬─┬─┬─┬─┬─┐          .───.
  #           ┌───────────│ │ │ │ │ │ │ │◀────────(  X  )◀───┐
  #           │           └─┴─┴─┴─┴─┴─┴─┘          `───'     │
  #           │                                              │
  # x-dead-letter-exchange                                   │
  #         binding                                          │
  #           │                                              │
  #           │                                            .───.
  #           │                                           (  C  ) consumer
  #           ▼                                            `───'
  #         .───.         ┌─┬─┬─┬─┬─┬─┬─┐                    ▲
  # ──────▶(  X  )───────▶│ │ │ │ │ │ │ │────────────────────┘
  #         `───'         └─┴─┴─┴─┴─┴─┴─┘
  #     work-exchange     work.queue
  #
  # The retry can be possible if the handler responds to `#requeue?` message
  # and it returns `true` in response. In order to prevent infinite loop of
  # retries there is a hard limit on the number of possible attempts.
  #
  # In case the handler does not implement `#requeue?` method, the environment
  # variable PTT_DEFAULT_RETRY is used to determine if the consumer should
  # retry the message delivery.
  class Consumer
    MAX_RETRIES = 10

    def initialize(channel, queue, retry_queue)
      @channel = channel
      @queue = queue
      @retry_queue = retry_queue
    end

    def subscribe(handler)
      @handler = handler
      @queue.subscribe(manual_ack: true, &method(:receive))
    end

    # The method is called when the consumer received the message from
    # the queue.
    #
    # In case the handler failes to process the payload, the delivery can be
    # retried. If it is not possible to retry the delivery, then the original
    # exception is re-raised.
    def receive(delivery_info, properties, body)
      @handler.call(JSON.parse(body))
    rescue => exception
      if should_retry?(exception) && can_retry?(properties)
        retry_delivery(properties, body)
      else
        raise exception
      end
    ensure
      @channel.ack(delivery_info.delivery_tag)
    end

    private

    def should_retry?(exception)
      if @handler.respond_to?(:requeue?)
        @handler.requeue?(exception)
      else
        ENV['PTT_DEFAULT_RETRY'] == 'true'
      end
    end

    def can_retry?(properties)
      headers = properties.headers || {}
      retry_count = headers.fetch('x-retry-count', 0)

      retry_count < MAX_RETRIES
    end

    def retry_delivery(properties, body)
      headers = properties.headers || {}
      retry_count = headers.fetch('x-retry-count', 0)
      ttl = ((retry_count**4) + 15 + (rand(30) * (retry_count + 1))).to_i*1000

      headers['x-retry-count'] = retry_count + 1

      @retry_queue.publish(body, expiration: ttl,
                                 headers: headers)
    end
  end
end
