require 'spec_helper'

describe 'enterprise magento under apache with single redis' do
  it_behaves_like 'magento under apache'
end

describe 'enterprise magento under mysql with single redis' do
  it_behaves_like 'magento under mysql'
end
