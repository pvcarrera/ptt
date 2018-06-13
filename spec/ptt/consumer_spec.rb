require 'ptt/consumer'

RSpec.describe PTT::Consumer do
  subject { described_class.new(channel, queue, retry_queue) }

  let(:channel) { double('Channel') }
  let(:queue) { double('Queue') }
  let(:retry_queue) { double('RetryQueue') }
  let(:handler) { double('Handler', call: nil) }

  before { allow(queue).to receive(:subscribe) }

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
    let(:properties) { double('Properties', headers: {}) }
    let(:body) { JSON.generate({ foo: 'bar' }) }
    let(:parsed_body) { JSON.parse(body) }

    before do
      allow(channel).to receive(:ack)
      subject.subscribe(handler)
    end

    shared_examples :successful_scheduled_retry do
      it 'should publish the message to the retry queue' do
        expect(retry_queue).to receive(:publish) do |payload, params|
          # Body should be published without changes
          expect(payload).to eq(body)
          # TTL range is calculated as:
          #
          #   ((retry_count ** 4) + 15 + (rand(30) * (retry_count + 1)))*1000
          #
          # where rand(30) is replaced with the possible maximum of 29.
          expect(0..74_000).to cover(params[:expiration])
          # Default retries counter value is 0, so incremented value is
          # expected to be 1.
          expect(params[:headers]['x-retry-count']).to eq(1)
        end
        subject.receive(delivery_info, properties, body)
      end
    end

    shared_examples :impossible_scheduled_retry do
      it 'should not publish the message to the retry queue' do
        expect(retry_queue).not_to receive(:publish)
        subject.receive(delivery_info, properties, body) rescue error
      end

      it 'should re-raise the exception' do
        expect { subject.receive(delivery_info, properties, body) }.to raise_error(error)
      end
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
      let(:error) { StandardError.new('Handler intensionally fails') }

      before do
        allow(handler).to receive(:call).and_raise(error)
      end

      it 'should acknowledge the message' do
        expect(channel).to receive(:ack).with(delivery_info.delivery_tag)
        subject.receive(delivery_info, properties, body) rescue error
      end

      context 'and the handler wants to retry' do
        before { allow(handler).to receive(:requeue?).and_return(true) }

        include_examples :successful_scheduled_retry

        context 'but the number of retries has been exhausted' do
          before do
            allow(properties).to receive(:headers).and_return({
              'x-retry-count' => PTT::Consumer::MAX_RETRIES
            })
          end

          include_examples :impossible_scheduled_retry
        end
      end

      context 'and the handler do not want to retry' do
        before { allow(handler).to receive(:requeue?).and_return(false) }

        include_examples :impossible_scheduled_retry
      end

      context 'and default retry is enabled' do
        let!(:original_ptt_default_retry) { ENV['PTT_DEFAULT_RETRY'] }

        before { ENV['PTT_DEFAULT_RETRY'] = 'true' }

        after { ENV['PTT_DEFAULT_RETRY'] = original_ptt_default_retry }

        include_examples :successful_scheduled_retry

        context 'but the number of retries has been exhausted' do
          before do
            allow(properties).to receive(:headers).and_return({
              'x-retry-count' => PTT::Consumer::MAX_RETRIES
            })
          end

          include_examples :impossible_scheduled_retry
        end
      end

      context 'and default retry is disabled' do
        let!(:original_ptt_default_retry) { ENV['PTT_DEFAULT_RETRY'] }

        before { ENV['PTT_DEFAULT_RETRY'] = 'false' }

        after { ENV['PTT_DEFAULT_RETRY'] = original_ptt_default_retry }

        it 'should not publish the message to the retry queue' do
          expect(retry_queue).not_to receive(:publish)
          subject.receive(delivery_info, properties, body) rescue error
        end

        it 'should re-raise the exception' do
          expect { subject.receive(delivery_info, properties, body) }.to raise_error(error)
        end
      end
    end
  end
end
