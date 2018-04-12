require 'ptt/consumer'

RSpec.describe PTT::Consumer do
  subject { described_class.new(channel, queue) }

  let(:channel) { double('Channel') }
  let(:queue) { double('Queue') }
  let(:handler) { Proc.new {} }
  let(:requeue_rejected) { nil }

  before do
    ENV['PTT_REQUEUE_REJECTED_MESSAGE'] = requeue_rejected
    allow(queue).to receive(:subscribe)
  end

  describe '#subscribe' do
    it 'should subscribe to designated queue' do
      expect(queue).to receive(:subscribe)
      subject.subscribe(handler)
    end
  end

  describe '#receive' do
    # `delivery_info`, `properties`, `body` are required parameters for Bunny
    # callback method
    let(:delivery_info) { double('DeliveryInfo', delivery_tag: 'quox') }
    let(:properties) { double('Properties') }
    let(:body) { JSON.generate({ foo: 'bar' }) }
    let(:parsed_body) { JSON.parse(body) }

    before do
      allow(channel).to receive(:ack)
      subject.subscribe(handler)
    end

    it 'should process parsed message body using designated handler' do
      expect(handler).to receive(:call).with(parsed_body)
      subject.receive(delivery_info, properties, body)
    end

    it 'should acknowledge the message' do
      expect(channel).to receive(:ack).with(delivery_info.delivery_tag)
      subject.receive(delivery_info, properties, body)
    end

    context 'when call to the handler fails' do
      before do
        allow(handler).to receive(:call).and_raise(StandardError.new(
          'Handler intensionally fails'
        ))
      end

      it 'should reject the message without requeueing' do
        expect(channel).to receive(:reject).with(
          delivery_info.delivery_tag,
          false
        )
        subject.receive(delivery_info, properties, body)
      end

      context 'and handler is set to requeu messages' do
        let(:handler) { double(:call, requeue?: true) }

        it 'should reject the message and add it back to the queue' do
          expect(channel).to receive(:reject).with(
            delivery_info.delivery_tag,
            true
          )
          subject.receive(delivery_info, properties, body)
        end
      end

      context 'and requeue ENV variable is set to true' do
        let(:requeue_rejected) { 'true' }

        it 'should reject the message and add it back to the queue' do
          expect(channel).to receive(:reject).with(
            delivery_info.delivery_tag,
            true
          )
          subject.receive(delivery_info, properties, body)
        end
      end
    end
  end
end
