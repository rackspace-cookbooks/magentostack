shared_examples_for 'magento enterprise edition' do
  # page hit to populate caches
  describe command('wget -qO- localhost:8080') do
    its(:stdout) { should match(/Magento Enterprise Edition Demo Store/) }
  end

  describe file('/mnt/magento_media') do
    it { should be_directory }
  end
end

shared_examples_for 'magento community edition' do
  # page hit to populate caches
  describe command('wget -qO- localhost:8080') do
    its(:stdout) { should match(/Magento Demo Store/) }
  end

  describe file('/mnt/magento_media') do
    it { should be_directory }
  end
end

shared_examples_for 'magento any edition' do
  # page hit to populate caches
  describe command('wget -qO- localhost:8080') do
    its(:stdout) { should match(/Demo Store/) }
  end

  describe file('/mnt/magento_media') do
    it { should be_directory }
  end
end
