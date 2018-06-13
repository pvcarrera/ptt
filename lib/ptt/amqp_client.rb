require 'bunny'

module PTT
  class AMQPClient
    class Error < StandardError
      def initialize(message, origin = nil)
        super(message)
        @origin = origin
      end
    end

    class ConnectionError < Error; end

    def connected?
      @connection && @connection.open?
    end

    def connect
      connection.start
    rescue Bunny::TCPConnectionFailed => exception
      raise ConnectionError.new(exception.message, exception)
    end

    def disconnect
      if connected?
        connection.close
        @connection = nil
      end
    end

    def channel
      @channel ||= begin
        channel = connection.create_channel
        channel.prefetch(1)
        channel
      end
    end

    def exchange
      @exchange ||= channel.direct('amq.direct', durable: true)
    end

    def retry_exchange
      @retry_exchange ||= channel.direct('amq.direct', durable: true)
    end

    def queue_for(routing_key)
      queue = channel.queue(routing_key, durable: true)
      queue.bind(exchange, routing_key: routing_key)

      queue
    end

    # The retry queue must be configured the way that the dead-letter exchange
    # is set to the main work exchange, so all expired messages are
    # automatically moved to the work exchange once on the moment of expired
    # TTL.
    #
    # Another important aspect of correctly working retry functionality is
    # the routing key for dead-lettering. Because the client used exchanges
    # of direct type, the key must be set. The routing key must match the name
    # of work queue.
    def retry_queue_for(routing_key)
      original_routing_key = routing_key
      routing_key = "#{routing_key}.retry"
      retry_queue = channel.queue(routing_key, durable: true,
                                               arguments: {
                                                 'x-dead-letter-exchange' => exchange.name,
                                                 'x-dead-letter-routing-key' => original_routing_key
                                               })
      retry_queue.bind(retry_exchange, routing_key: routing_key)

      retry_queue
    end

    private

    def connection
      @connection ||= Bunny.new(ENV['RABBITMQ_URL'])
    end
  end
end
