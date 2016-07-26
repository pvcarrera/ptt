require 'ptt/null_exchange'

RSpec.describe PTT::NullExchange do
  it { is_expected.to respond_to(:publish) }
end
