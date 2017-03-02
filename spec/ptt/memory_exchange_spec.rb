require 'ptt/memory_exchange'
require 'ptt/memory_queue'

# Because there is no direct way to access queues registered on the exchange.
# all tests are based on side effect of using a in-memory queue - all incoming
# messages are processed by the handler immediately.
RSpec.describe PTT::MemoryExchange do
  before do
    $stdout = StringIO.new
  end

  after do
    $stdout = STDOUT
  end

  describe '#register_queue' do
    it 'registers the queue by given routing key' do
      queue = PTT::MemoryQueue.new
      handler = -> (delivery_info, properties, data) { puts data }
      queue.subscribe({}, &handler)

      subject.register_queue('foo', queue)
      subject.publish('Hello from the queue', routing_key: 'foo')

      expect($stdout.string).to include('Hello from the queue')
    end
  end

  describe '#publish' do
    it 'passes data to the queue by given routing key' do
      queue = PTT::MemoryQueue.new
      handler = -> (delivery_info, properties, data) { puts data }
      queue.bind(subject, routing_key: 'foo')
      queue.subscribe({}, &handler)

      subject.publish('Hello World', routing_key: 'foo')

      expect($stdout.string).to include('Hello World')
    end
  end
end
