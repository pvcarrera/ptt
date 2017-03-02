require 'ptt/memory_queue'
require 'ptt/memory_exchange'

RSpec.describe PTT::MemoryQueue do
  before do
    $stdout = StringIO.new
  end

  after do
    $stdout = STDOUT
  end

  describe '#bind' do
    it 'registers the queue on the given exchange by given routing key' do
      exchange = PTT::MemoryExchange.new
      allow(exchange).to receive(:register_queue)

      expect(exchange).to receive(:register_queue).with('foo', subject)
      subject.bind(exchange, routing_key: 'foo')
    end
  end

  describe '#subscribe' do
    # There is no direct way to check is a handler was set or not, that is why
    # the test uses `#process` method - the `#process` method calls the handler.
    it 'registers a given message handler' do
      options = {}
      handler = -> (delivery_info, properties, data) { puts 'Hello World' }

      subject.subscribe(options, &handler)
      subject.process({}, {}, '')

      expect($stdout.string).to include('Hello World')
    end
  end

  describe '#process' do
    it 'calls the message handler with given params' do
      options = {}
      handler = -> (delivery_info, properties, data) { puts "Data: #{data}" }
      subject.subscribe(options, &handler)

      delivery_info = {}
      properties = {}
      data = 'foo'
      subject.process(delivery_info, properties, data)

      expect($stdout.string).to include('Data: foo')
    end
  end
end
