# Encoding: utf-8

require 'spec_helper'

# on rhel/debian flavors both
redis_path = '/usr/local/bin'

## redis single
# redis itself
describe service('redis6379-single-master') do
  it { should be_enabled }
end
describe port(6379) do
  it { should be_listening }
end
describe file('/etc/redis/6379-single-master.conf') do
  it { should be_file }
end
describe command("#{redis_path}/redis-cli -a runstatepasswordsingle -p 6379 INFO") do
  its(:stdout) { should match(/role:master/) }
  its(:stdout) { should match(/connected_slaves:1/) }
end

# redis slave
describe service('redis6380-single-slave') do
  it { should be_enabled }
end
describe port(6380) do
  it { should be_listening }
end
describe file('/etc/redis/6380-single-slave.conf') do
  it { should be_file }
end
describe command("#{redis_path}/redis-cli -a runstatepasswordsingle -p 6380 INFO") do
  its(:stdout) { should match(/role:slave/) }
  its(:stdout) { should match(/master_host:.+/) }
  its(:stdout) { should match(/master_port:6379/) }
  its(:stdout) { should match(/master_link_status:up/) }
end

# sentinel for single
describe service('redis_sentinel_46379-sentinel') do
  it { should be_enabled }
end
describe port(46_379) do
  it { should be_listening }
end
describe file('/etc/redis/sentinel_46379-sentinel.conf') do
  it { should be_file }
  its(:content) { should match(/sentinel monitor .+ 6379 2/) }
end
describe command("#{redis_path}/redis-cli -a runstatepasswordsingle -p 46379 SENTINEL masters") do
  its(:stdout) { should match(/port\n6379/) }
end
