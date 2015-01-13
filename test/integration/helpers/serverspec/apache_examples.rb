
shared_examples_for 'magento under apache' do |args|
  # Apache-fpm
  if os[:family] == 'redhat'
    docroot = '/var/www/html/magento'
    apache_service_name = 'httpd'
    fpm_service_name = 'php-fpm'
    apache2ctl = '/usr/sbin/apachectl'
  else
    docroot = '/var/www/magento'
    apache_service_name = 'apache2'
    fpm_service_name = 'php5-fpm'
    apache2ctl = '/usr/sbin/apache2ctl'
  end

  describe service(apache_service_name) do
    it { should be_enabled }
    it { should be_running }
  end

  describe service(fpm_service_name) do
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

  ## Create an index.php for testing purpose
  ## using wget because curl is nto there by default on ubuntu
  describe command('wget -qO- localhost:8080/phpinfo.php') do
    index_php_path = "#{docroot}/phpinfo.php"
    before do
      File.open(index_php_path, 'w') { |file| file.write('<?php phpinfo(); ?>') }
    end
    its(:stdout) { should match(/FPM\/FastCGI/) }
    its(:stdout) { should match(/PHP Version 5.5/) }
    # Opcache
    its(:stdout) { should match(/opcache.enable<\/td><td class="v">On/) }
    its(:stdout) { should match(/opcache.memory_consumption<\/td><td class="v">256/) }
    its(:stdout) { should match(/opcache.interned_strings_buffer<\/td><td class="v">8/) }
    its(:stdout) { should match(/opcache.max_accelerated_files<\/td><td class="v">4000/) }
    its(:stdout) { should match(/opcache.fast_shutdown<\/td><td class="v">1/) }
    its(:stdout) { should match(/opcache.validate_timestamps<\/td><td class="v">Off/) }
  end

  ## use http://www.magentocommerce.com/knowledge-base/entry/how-do-i-know-if-my-server-is-compatible-with-magento
  describe command('wget -qO- localhost:8080/magento-check.php') do
    before do
      File.open("#{docroot}/magento-check.php", 'w') { |file| file.write(File.read("#{ENV['BUSSER_ROOT']}/suites/serverspec/fixtures/magento-check.php")) }
    end
    its(:stdout) { should match(/Congratulations/) }
    after do
      File.delete("#{docroot}/magento-check.php")
    end
  end
end
