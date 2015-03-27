require 'spec_helper'

describe 'community magento under apache with single redis' do
  it_behaves_like 'magento under apache'
end

describe 'community magento under mysql with single redis' do
  it_behaves_like 'magento under mysql'
end

describe 'community magento with php55' do
  it_behaves_like 'php55 under apache'
end

describe file('/var/www/html/magento/app/etc/local.xml') do
  context 'encryption key in local.xml' do
    its(:content) { should match(/abc123/) }
  end

  context 'admin front name in local.xml' do
    its(:content) { should match(/superstore/) }
  end

  context 'database prefix in local.xml' do
    its(:content) { should match(/moverride_/) }
  end
end
