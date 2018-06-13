require 'ptt/amqp_client'

RSpec.describe PTT::AMQPClient do
  before { subject.connect }

  after { subject.disconnect }

  describe '#exchange' do
    it 'should return a direct exchange' do
      expect(subject.exchange.type).to eq(:direct)
    end

    it 'should reuse default direct exchange' do
      expect(subject.exchange.name).to eq('amq.direct')
    end

    it 'should create a durable exchange' do
      expect(subject.exchange).to be_durable
    end
  end

  describe '#retry_exchange' do
    it 'should return a direct exchange' do
      expect(subject.retry_exchange.type).to eq(:direct)
    end

    it 'should reuse default direct exchange' do
      expect(subject.retry_exchange.name).to eq('amq.direct')
    end

    it 'should create a durable exchange' do
      expect(subject.retry_exchange).to be_durable
    end
  end

  describe '#queue_for' do
    it 'should create a durable queue' do
      queue = subject.queue_for('foo')

      expect(queue).to be_durable
    end
  end

  describe '#retry_queue_for' do
    it 'should create a durable queue' do
      queue = subject.retry_queue_for('foo')

      expect(queue).to be_durable
    end

    it 'should add ".retry" suffix to the given routing key' do
      queue = subject.retry_queue_for('foo')

      expect(queue.name).to eq('foo.retry')
    end

    it 'should configure the queue for dead lettering' do
      queue = subject.retry_queue_for('foo')

      expect(queue.arguments).to include({
        'x-dead-letter-exchange' => subject.exchange.name,
        'x-dead-letter-routing-key' => 'foo'
      })
    end
  end
end
