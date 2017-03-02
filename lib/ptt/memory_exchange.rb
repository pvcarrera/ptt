require 'securerandom'
require 'ostruct'

require 'ptt/null_queue'

module PTT
  # Public: In-Memory exchange calls queue handlers immediately after something
  # has been published.
  #
  # It is used by in-memory client (see MemoryClient class).
  class MemoryExchange
    def register_queue(routing_key, queue)
      queues[routing_key] = queue
      nil
    end

    def publish(data, options = {})
      routing_key = options[:routing_key]
      queue = queues[routing_key]

      delivery_info = OpenStruct.new(delivery_tag: SecureRandom.hex)
      properties = {}
      queue.process(delivery_info, properties, data)
    end

    private

    def queues
      @queues ||= Hash.new(MemoryQueue.new)
    end
  end
end
