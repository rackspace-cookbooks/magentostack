require 'spec_helper'

describe port(8080) do
  it { should be_listening }
end
describe port(8443) do
  it { is_expected.to_not be_listening }
end
