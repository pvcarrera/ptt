require 'json'

module PTT
  class Publisher
    def initialize(exchange)
      @exchange = exchange
    end

    def publish(routing_key, data)
      @exchange.publish(JSON.generate(data), routing_key: routing_key)
    end
  end
end
