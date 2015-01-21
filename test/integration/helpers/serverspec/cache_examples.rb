redis_path = '/usr/local/bin'

def clear_out_redis(args, redis_path = '/usr/local/bin')
  cmd = "#{redis_path}/redis-cli #{args} --no-raw flushdb"
  puts "#{cmd}\n"
  system(cmd)
end

def flush_all_magento_caches
  File.open("#{docroot}/magento-clean-caches.php", 'w') { |file| file.write(File.read("#{ENV['BUSSER_ROOT']}/suites/serverspec/fixtures/magento-clean-caches.php")) }
  cmd = "php #{docroot}/magento-clean-caches.php"
  puts "#{cmd}\n"
  system(cmd)
end

shared_examples_for 'magento redis cache' do |args|
  args = '' unless args

  # page hit to populate caches
  it_behaves_like 'magento any edition'

  # ensure the cache is non-empty now
  describe command("sleep 5 && #{redis_path}/redis-cli #{args} --no-raw keys '*'") do
    its(:stdout) { should_not match(/empty list or set/) }
  end
end
