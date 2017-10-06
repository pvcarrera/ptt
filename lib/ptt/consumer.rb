require 'json'

module PTT
  class Consumer
    def initialize(channel, queue)
      @channel = channel
      @queue = queue
    end

    def subscribe(handler)
      @handler = handler
      @queue.subscribe(manual_ack: true, &method(:receive))
    end

    def receive(delivery_info, properties, body)
      @handler.call(JSON.parse(body))
      @channel.ack(delivery_info.delivery_tag)
    rescue => e
      @channel.reject(delivery_info.delivery_tag, false)
    end
  end
end
