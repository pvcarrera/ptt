module PTT
  class MemoryQueue
    # Public: In-memory queue is used together with in-memory client.
    # See MemoryClient class for more details.
    def bind(exchange, options = {})
      routing_key = options[:routing_key]
      exchange.register_queue(routing_key, self)
    end

    def subscribe(options, &handler)
      self.handler = handler
      nil
    end

    def process(delivery_info, properties, data)
      handler.call(delivery_info, properties, data)
    end

    private

    attr_writer :handler

    def handler
      @handler ||= Proc.new {}
    end
  end
end
