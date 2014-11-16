require 'ptt/publisher'

RSpec.describe PTT::Publisher do
  subject { described_class.new(exchange) }

  let(:exchange) { double('Exchange') }

  describe '#publish' do
    let(:data) { { foo: 'bar' } }
    let(:routing_key) { 'foo' }
    let(:json_data) { JSON.generate(data) }

    before do
      allow(exchange).to receive(:publish)
    end

    it 'should publish data to designated exchange with given routing key' do
      expect(exchange).to receive(:publish).with(
        json_data, routing_key: routing_key
      )
      subject.publish(routing_key, data)
    end
  end

end
