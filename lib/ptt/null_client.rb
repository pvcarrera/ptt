require 'ptt/null_exchange'
require 'ptt/null_queue'

module PTT
  # Public: Implementation of the null-object pattern for an AMQP client.
  # The class is useful when you test your app or library.
  #
  # The class mimics the interface of AMQPClient. So see this class for
  # more details.
  #
  # Examples
  #
  #   require 'ptt/null_client'
  #
  #   PTT.configure do |ptt|
  #     ptt.client = PTT::NullClient.new
  #   end
  class NullClient
    def connected?
      @connected
    end

    def connect
      @connected = true
    end

    def disconnect
      @connected = false
    end

    def channel
    end

    def exchange
      @exchange ||= NullExchange.new
    end

    def queue_for(routing_key)
      queues[routing_key]
    end

    private

    def queues
      @queues ||= Hash.new(NullQueue.new)
    end
  end
end
