# Encoding: utf-8

require_relative 'spec_helper'

# apache
if os[:family] == 'redhat'
  describe service('httpd') do
    it { should be_enabled }
  end
  apache2ctl = '/usr/sbin/apachectl'
else
  describe service('apache2') do
    it { should be_enabled }
  end
  apache2ctl = '/usr/sbin/apache2ctl'
end
describe port(80) do
  it { should be_listening }
end
describe port(443) do
  it { should be_listening }
end
describe command("#{apache2ctl} -M") do
  its(:stdout) { should match(/^ ssl_module/) }
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
