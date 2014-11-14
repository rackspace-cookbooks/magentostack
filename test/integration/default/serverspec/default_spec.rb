# Encoding: utf-8

require_relative 'spec_helper'

# Apache-fpm
if os[:family] == 'redhat'
  describe service('httpd') do
    it { should be_enabled }
    it { should be_running }
  end
  apache2ctl = '/usr/sbin/apachectl'
else
  describe service('apache2') do
    it { should be_enabled }
    it { should be_running }
  end
  apache2ctl = '/usr/sbin/apache2ctl'
end
describe port(80) do
  it { should be_listening }
end
describe port(443) do
  it { should be_listening }
end

describe service('php-fpm') do
  it { should be_enabled }
  it { should be_running }
end

%w(
  status actions alias auth_basic
  authn_file authz_default
  authz_groupfile authz_host
  authz_user autoindex dir env mime
  negotiation setenvif ssl headers
  expires log_config logio fastcgi
).each do |mod|
  describe command("#{apache2ctl} -M") do
    its(:stdout) { should match(/^ #{mod}_module/) }
  end
end

describe command("#{apache2ctl} -M") do
  its(:stdout) { should match(/^ ssl_module/) }
end

describe command("#{apache2ctl} -t") do
  its(:exit_status) { should eq 0 }
end

describe command("#{apache2ctl} -S") do
  its(:stdout) { should match(/port 443 namevhost mymagento.com/) }
  its(:stdout) { should match(/port 80 namevhost mymagento.com/) }
end

if os[:family] == 'redhat'
  describe file('/var/www/html/magento') do
    it { should be_directory }
  end
else
  describe file('/var/www/magento') do
    it { should be_directory }
  end
end

# redis
# cannot name the service redis6379 because the check uses ps, not the actual service name
describe service('redis') do
  it { should be_running }
end
if os[:family] == 'redhat'
  describe service('redis6379') do
    it { should be_enabled }
  end
end
describe port(6379) do
  it { should be_listening }
end
