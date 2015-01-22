shared_examples_for 'magento under apache' do |args|
  describe service(apache_service_name) do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8080) do
    it { should be_listening }
  end
  describe port(8443) do
    it { should be_listening }
  end

  modules = %w(
    status actions alias auth_basic
    authn_file authz_groupfile authz_host
    authz_user autoindex dir env mime
    negotiation setenvif ssl headers
    expires log_config logio fastcgi
  )
  # Apache 2.4(default on Ubuntu 14) doesn't have the authz_default module
  modules << 'authz_default' unless os[:release] == '14.04'
  modules.each do |mod|
    describe command("#{apache2ctl} -M") do
      its(:stdout) { should match(/^ #{mod}_module/) }
    end
  end

  ## test configuration syntax
  describe command("#{apache2ctl} -t") do
    its(:exit_status) { should eq 0 }
  end

  ## apachectl -S on Apache 2.4(default on Ubuntu 14) has a different output
  if os[:release] == '14.04'
    describe command("#{apache2ctl} -S") do
      its(:stdout) { should match(/\*:8443 .\*localhost/) }
      its(:stdout) { should match(/\*:8080 .\*localhost/) }
    end
  else
    describe command("#{apache2ctl} -S") do
      its(:stdout) { should match(/port 8443 namevhost localhost/) }
      its(:stdout) { should match(/port 8080 namevhost localhost/) }
    end
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
