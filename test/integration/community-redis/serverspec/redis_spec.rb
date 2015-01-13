# Encoding: utf-8

require 'spec_helper'

# on rhel/debian flavors both
redis_path = '/usr/local/bin'

# expected instances hard coded
redis = {
  '6381-session-master' => { 'port' => 6381, 'password' => 'runstatepasswordsession' },
  '6383-object-master' => { 'port' => 6383, 'password' => 'runstatepasswordobject' },
  '6385-page-master' => { 'port' => 6385, 'password' => 'runstatepasswordpage' }
}

## redis expanded (separate instances)
redis.each do |k, v|
  describe service("redis#{k}") do
    it { should be_enabled }
  end
  describe port(v['port']) do
    it { should be_listening }
  end
  describe file("/etc/redis/#{k}.conf") do
    it { should be_file }
  end
  describe command("#{redis_path}/redis-cli -a #{v['password']} -p #{v['port']} INFO") do
    its(:stdout) { should match(/role:master/) }
  end
end

# redis slave instances hard coded
slaves = {
  '6382-session-slave' => { 'port' => 6382, 'password' => 'runstatepasswordsession' },
  '6384-object-slave' => { 'port' => 6384, 'password' => 'runstatepasswordobject' },
  '6386-page-slave' => { 'port' => 6386, 'password' => 'runstatepasswordpage' }
}

## redis expanded (separate instances)
slaves.each do |k, v|
  describe service("redis#{k}") do
    it { should be_enabled }
  end
  describe port(v['port']) do
    it { should be_listening }
  end
  describe file("/etc/redis/#{k}.conf") do
    it { should be_file }
  end

  describe command("#{redis_path}/redis-cli -a #{v['password']} -p #{v['port']} INFO") do
    its(:stdout) { should match(/role:slave/) }
    its(:stdout) { should match(/master_host:.+/) }
    its(:stdout) { should match(/master_port:#{v['port'] - 1}/) }
    its(:stdout) { should match(/master_link_status:up/) }
  end
end

# sentinel for session redis
describe service('redis_sentinel_46379-sentinel') do
  it { should be_enabled }
end
describe port(46_379) do
  it { should be_listening }
end
describe file('/etc/redis/sentinel_46379-sentinel.conf') do
  it { should be_file }
  its(:content) { should match(/sentinel monitor .+ 6381 2/) }
end
describe command("#{redis_path}/redis-cli -a runstatepasswordsession -p 46379 SENTINEL masters") do
  its(:stdout) { should match(/port\n6381/) }
end
