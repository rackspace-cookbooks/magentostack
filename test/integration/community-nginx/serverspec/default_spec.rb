require 'spec_helper'

describe 'community magento under nginx with single redis' do
  it_behaves_like 'magento under nginx'
end

describe 'community magento under mysql with single redis' do
  it_behaves_like 'magento under mysql'
end

describe 'community magento with php55' do
  it_behaves_like 'php55 under php-fpm'
end
