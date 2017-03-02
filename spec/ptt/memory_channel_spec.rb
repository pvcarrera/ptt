require 'ptt/memory_channel'

RSpec.describe PTT::MemoryChannel do
  it { is_expected.to respond_to(:ack) }
end
