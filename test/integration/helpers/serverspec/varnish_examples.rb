shared_examples_for 'magento under varnish' do |args|
  describe file('/usr/local/bin/modman') do
    it { should exist }
  end

  describe file('/var/www/html/.modman') do
    it { should exist }
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
    its(:stdout) { should match(/Congratulations/) }
  end

  # verify varnish works
  describe command('wget -qO- localhost:8181') do
    its(:stdout) { should match(/Congratulations/) }
  end

  # verify varnish with SSL flag works
  describe command("wget -qO- localhost:8181/admin --header='X-Forwarded-Proto: https'") do
    its(:stdout) { should match(/Congratulations/) }
  end
end
