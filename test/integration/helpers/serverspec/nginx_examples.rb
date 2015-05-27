shared_examples_for 'magento under nginx' do |args|
  describe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8080) do
    it { should be_listening }
  end
  describe port(8443) do
    it { should be_listening }
  end

  ## nginx configtest
  describe command("/etc/init.d/nginx configtest") do
    its(:stdout) { should match %r{nginx: the configuration file /etc/nginx/nginx.conf syntax is ok} }
    its(:stdout) { should match %r{nginx: configuration file /etc/nginx/nginx.conf test is successful} }
  end


  describe file(docroot) do
    it { should be_directory }
  end

  ## use http://www.magentocommerce.com/knowledge-base/entry/how-do-i-know-if-my-server-is-compatible-with-magento
  describe command('wget -qO- localhost:8080/magento-check.php') do
    before do
      File.open("#{docroot}/magento-check.php", 'w') { |file| file.write(File.read("#{ENV['BUSSER_ROOT']}/suites/serverspec/fixtures/magento-check.php")) }
    end
    its(:stdout) { should match(/Congratulations/) }
  end
end
