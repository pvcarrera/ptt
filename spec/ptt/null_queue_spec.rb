require 'ptt/null_queue'

RSpec.describe PTT::NullQueue do
  it { is_expected.to respond_to(:subscribe) }
end
