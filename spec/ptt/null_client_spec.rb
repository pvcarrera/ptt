require 'ptt/null_client'

RSpec.describe PTT::NullClient do
  it { is_expected.to respond_to(:connect) }

  it { is_expected.to respond_to(:disconnect) }

  it { is_expected.to respond_to(:channel) }

  it { is_expected.to respond_to(:exchange) }

  it { is_expected.to respond_to(:queue_for) }

  describe '#exchange' do
    it 'returns an instance of NullExchange' do
      expect(subject.exchange).to be_a(PTT::NullExchange)
    end
  end

  describe '#queue_for' do
    let(:routing_key) { 'foo' }

    it 'returns an instance of NullQueue' do
      queue = subject.queue_for(routing_key)

      expect(queue).to be_a(PTT::NullQueue)
    end

    it 'memoizes values for routing keys' do
      queue1 = subject.queue_for(routing_key)
      queue2 = subject.queue_for(routing_key)

      expect(queue1).to be_equal(queue2)
    end
  end

  describe '#retry_queue_for' do
    it 'returns an instance of NullQueue' do
      expect(subject.retry_queue_for('foo')).to be_a(PTT::NullQueue)
    end
  end
end
