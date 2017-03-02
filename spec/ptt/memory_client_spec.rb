require 'ptt'
require 'ptt/memory_client'

RSpec.describe PTT::MemoryClient do
  it { is_expected.to respond_to(:connect) }

  it { is_expected.to respond_to(:disconnect) }

  describe '#channel' do
    it 'returns an instance of MemoryChannel' do
      expect(subject.channel).to be_a(PTT::MemoryChannel)
    end
  end

  describe '#exchange' do
    it 'returns an instance of MemoryExchange' do
      expect(subject.exchange).to be_a(PTT::MemoryExchange)
    end
  end

  describe '#queue_for' do
    it 'returns an instance of MemoryQueue' do
      expect(subject.queue_for('foo')).to be_a(PTT::MemoryQueue)
    end
  end
end
