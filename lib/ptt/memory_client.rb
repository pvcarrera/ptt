require 'ptt/memory_channel'
require 'ptt/memory_exchange'
require 'ptt/memory_queue'

module PTT
  # Public: In-memory client that might be useful for testing. Any message
  # published using this client is immediatelly processed by the handler
  # registered on the queue.
  #
  # No RabbitMQ required for the in-memory client. All queues registered with
  # the in-memory client automatically binded to the in-memory exchange
  # (see MemoryExchange class).
  #
  # Examples
  #
  #   PTT.configure do |ptt|
  #     ptt.client = PTT::MemoryClient.new
  #   end
  #   PTT.connect
  #
  #   PTT.register_handler('foo', -> (payload) { p(payload) })
  #
  #   PTT.publish('foo', { bar: 'baz' })
  #   #=> { bar: 'baz' }
  class MemoryClient
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
      @channel ||= MemoryChannel.new
    end

    def exchange
      @exchange ||= MemoryExchange.new
    end

    def queue_for(routing_key)
      queues[routing_key]
    end

    def retry_queue_for(routing_key)
      routing_key = "#{routing_key}.retry"
      queues[routing_key]
    end

    private

    def queues
      @queues ||= Hash.new do |hash, key|
        queue = MemoryQueue.new
        queue.bind(exchange, routing_key: key)
        hash[key] = queue
      end
    end
  end
end
