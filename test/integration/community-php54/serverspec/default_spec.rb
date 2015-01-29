require 'spec_helper'

describe 'community magento under apache with single redis' do
  it_behaves_like 'magento under apache'
end

describe 'community magento under mysql with single redis' do
  it_behaves_like 'magento under mysql'
end

describe 'community magento with php54' do
  it_behaves_like 'php54 under apache'
end

describe 'community magento' do
  it_behaves_like 'magento community edition'
end
