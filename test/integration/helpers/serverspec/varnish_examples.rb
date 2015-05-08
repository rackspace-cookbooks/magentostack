shared_examples_for 'magento under varnish' do |args|
  describe file('/usr/local/bin/modman') do
    it { should be_file }
  end

  describe file('/var/www/html/.modman') do
    it { should be_directory }
  end

  describe service('varnish') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8181) do
    it { should be_listening }
  end

  # verify SSL flag works
  describe command("wget -qO- localhost:8080/admin --header='X-Forwarded-Proto: https'") do
    its(:stdout) { should match(/Log into Magento Admin Page/) }
  end

  # verify varnish works
  describe command('wget -qO- localhost:8181/admin') do
    its(:stdout) { should_not match(/Congratulations/) }
  end

  # verify varnish with SSL flag works
  describe command("wget -qO- localhost:8181/admin --header='X-Forwarded-Proto: https'") do
    its(:stdout) { should match(/Log into Magento Admin Page/) }
  end

  # be sure turpentine created a ruleset in varnish
  describe command('php /var/www/html/magento/enable-magento-turpentine.php >/dev/null 2>&1; varnishadm vcl.list | grep -v boot') do
    its(:stdout) { should match(/active/) }
  end
end
