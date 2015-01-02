require_relative 'spec_helper'

redis_path = '/usr/local/bin'

# object cache (magento calls this the 'cache', in redis db 0)
describe 'redis instance for object cache' do
  # empty database 0
  describe command("#{redis_path}/redis-cli --no-raw -n 0 flushdb") do
    its(:exit_status) { should eq(0) }
  end

  # ensure there are no keys
  describe command("#{redis_path}/redis-cli --no-raw -n 0 keys '*'") do
    its(:stdout) { should match(/empty list or set/) }
  end

  # page hit to populate caches
  describe command('wget -qO- localhost:8080') do
    its(:stdout) { should match(/Magento Demo Store/) }
  end

  # ensure the cache is non-empty now
  describe command("#{redis_path}/redis-cli --no-raw -n 0 keys '*'") do
    its(:stdout) { should_not match(/empty list or set/) }
  end
end

# session cache (magento calls this the 'cache', in redis db 2)
describe 'redis instance for session cache' do
  # empty database 0
  describe command("#{redis_path}/redis-cli --no-raw -n 2 flushdb") do
    its(:exit_status) { should eq(0) }
  end

  # ensure there are no keys
  describe command("#{redis_path}/redis-cli --no-raw -n 2 keys '*'") do
    its(:stdout) { should match(/empty list or set/) }
  end

  # page hit to populate caches
  describe command('wget -qO- localhost:8080') do
    its(:stdout) { should match(/Magento Demo Store/) }
  end

  # ensure the cache is non-empty now
  describe command("#{redis_path}/redis-cli --no-raw -n 2 keys '*'") do
    its(:stdout) { should_not match(/empty list or set/) }
  end
end
