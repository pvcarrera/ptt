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

    def queue_for(routing_key)
      queue = channel.queue(routing_key, durable: true)
      queue.bind(exchange, routing_key: routing_key)
      queue
    end

    private

    def connection
      @connection ||= Bunny.new(ENV['RABBITMQ_URL'])
    end
  end
end
