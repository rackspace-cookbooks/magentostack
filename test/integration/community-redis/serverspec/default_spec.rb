# Encoding: utf-8

require 'spec_helper'

describe 'community magento under apache with multiple redis' do
  it_behaves_like 'magento under apache'
end

describe 'community magento under mysql with multiple redis' do
  it_behaves_like 'magento under mysql'
end
