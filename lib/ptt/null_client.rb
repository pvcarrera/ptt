module PTT
  class NullClient
    class NullQueue
      def subscribe(handler); end
    end

    def connect
    end

    def disconnect
    end

    def channel
    end

    def exchange
    end

    def queue_for(routing_key)
      NullQueue.new
    end
  end
end
