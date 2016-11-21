require 'ptt'
require 'ptt/null_client'

RSpec.describe PTT do
  subject { described_class }

  let(:amqp_client) { PTT::NullClient.new }
  let(:handler) { Proc.new {  } }


  before do
    subject.client = amqp_client
  end

  describe '.configure' do
    pending
  end

  describe '.connect' do
    before do
      allow(amqp_client).to receive(:connect)
    end

    it 'should start AMQP connection' do
      expect(amqp_client).to receive(:connect)
      subject.connect
    end

    it 'should subscribe all available consumers' do
      allow(subject).to receive(:subscribe)
      subject.register_handler('foo', handler)
      expect(subject).not_to have_received(:subscribe)

      expect(subject).to receive(:subscribe).with('foo', handler)
      subject.connect
    end
  end

  describe '.disconnect' do
    before do
      allow(amqp_client).to receive(:disconnect)
    end

    it 'should close AMQP connection' do
      expect(amqp_client).to receive(:disconnect)
      subject.disconnect
    end
  end

  describe '.register_handler' do
    it 'should register a message handler by given routing key' do
      subject.register_handler('foo', handler)
      expect(subject.handler_for('foo')).to eq(handler)
    end

    it 'should subscribe immediately if connected' do
      subject.connect

      allow(amqp_client).to receive(:connected?).and_return(true)
      expect(subject).to receive(:subscribe).with('foo', handler)
      subject.register_handler('foo', handler)
    end
  end

  describe '.handler_for' do
    let(:handler) { Proc.new {  } }

    before do
      subject.register_handler('foo', handler)
    end

    it 'should return a registered a message handler by given routing key' do
      expect(subject.handler_for('foo')).to eq(handler)
    end
  end

  describe '.publish' do
    let(:publisher) { instance_double(PTT::Publisher) }
    let(:data) { { foo: 'bar' } }
    let(:routing_key) { 'foo' }

    before do
      allow(publisher).to receive(:publish)
      subject.publisher = publisher
    end

    it 'should publish data with given routing key' do
      expect(publisher).to receive(:publish).with(routing_key, data)
      subject.publish(routing_key, data)
    end
  end
end
