shared_examples_for 'magento database configuration' do
  describe file('/var/www/html/magento/app/etc/local.xml') do
    parts_expected = [
      %r{<host><!\[CDATA\[.*\]\]></host>},
      %r{<username><!\[CDATA\[.*\]\]></username>},
      %r{<password><!\[CDATA\[.*\]\]></password>},
      %r{<dbname><!\[CDATA\[.*\]\]></dbname>},
      %r{<initStatements><!\[CDATA\[SET NAMES utf8\]\]></initStatements>},
      %r{<model><!\[CDATA\[mysql4\]\]></model>},
      %r{<type><!\[CDATA\[pdo_mysql\]\]></type>},
      %r{<pdoType><!\[CDATA\[.*\]\]></pdoType>},
      %r{<active>1</active>},
      %r{<persistent>1</persistent>}
    ]

    parts_expected.each do |r|
      its(:content) { should match(r) }
    end
  end
end

shared_examples_for 'magento enterprise edition' do
  # page hit to populate caches
  describe command('wget -qO- localhost:8080') do
    its(:stdout) { should match(/Magento Enterprise Edition Demo Store/) }
  end

  describe file('/mnt/magento_media') do
    it { should be_directory }
  end

  it_behaves_like 'magento database configuration'
end

shared_examples_for 'magento community edition' do
  # page hit to populate caches
  describe command('wget -qO- localhost:8080') do
    its(:stdout) { should match(/Magento Demo Store/) }
  end

  # ensure git dirs aren't exposed
  describe command('wget -O- localhost:8080/.git/ 2>&1') do
    its(:stdout) { should match(/Forbidden/) }
    its(:stdout) { should match(/403/) }
    its(:stdout) { should_not match(/Index of/) }
    its(:exit_status) { should_not eq 0 }
  end

  describe file('/mnt/magento_media') do
    it { should be_directory }
  end

  it_behaves_like 'magento database configuration'
end

shared_examples_for 'magento any edition' do
  # page hit to populate caches
  describe command('wget -qO- localhost:8080') do
    its(:stdout) { should match(/Demo Store/) }
  end

  describe file('/mnt/magento_media') do
    it { should be_directory }
  end

  it_behaves_like 'magento database configuration'
end
