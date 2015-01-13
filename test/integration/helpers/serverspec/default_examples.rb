shared_examples_for 'magento enterprise edition' do
  # page hit to populate caches
  describe command('wget -qO- localhost:8080') do
    its(:stdout) { should match(/Magento Enterprise Edition Demo Store/) }
  end
end

shared_examples_for 'magento community edition' do
  # page hit to populate caches
  describe command('wget -qO- localhost:8080') do
    its(:stdout) { should match(/Magento Demo Store/) }
  end
end

shared_examples_for 'magento any edition' do
  # page hit to populate caches
  describe command('wget -qO- localhost:8080') do
    its(:stdout) { should match(/Demo Store/) }
  end
end

redis_path = '/usr/local/bin'
shared_examples_for 'magento redis cache' do |args|
  args = '' unless args

  # page hit to populate caches
  it_behaves_like 'magento any edition'

  # ensure the cache is non-empty now
  describe command("sleep 5 && #{redis_path}/redis-cli #{args} --no-raw keys '*'") do
    its(:stdout) { should_not match(/empty list or set/) }
  end
end
