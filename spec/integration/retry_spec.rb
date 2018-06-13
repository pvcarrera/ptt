require 'ptt'
require 'ptt/amqp_client'

RSpec.describe 'Retry feature' do
  let(:client) { PTT::AMQPClient.new }

  before do
    PTT.client = client
    PTT.connect
  end

  after do
    PTT.disconnect
  end

  context 'when a handler is registered' do
    before { PTT.register_handler('foo', Proc.new {}) }

    it 'should create and configure work and retry queues' do
      queues = client.channel.queues
      work_queue = queues['foo']
      retry_queue = queues['foo.retry']

      expect(work_queue).not_to be_nil
      expect(retry_queue).not_to be_nil
      expect(retry_queue.arguments).to include({
        'x-dead-letter-exchange' => client.exchange.name,
        'x-dead-letter-routing-key' => work_queue.name
      })
    end
  end
end
