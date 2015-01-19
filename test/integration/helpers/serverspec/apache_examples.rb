def redhat_family_values
  res = {}
  res['docroot'] = '/var/www/html/magento'
  res['apache_service_name'] = 'httpd'
  res['fpm_service_name'] = 'php-fpm'
  res['apache2ctl'] = '/usr/sbin/apachectl'
  res
end

def debian_family_values
  res = {}
  res['docroot'] = '/var/www/magento'
  res['apache_service_name'] = 'apache2'
  res['fpm_service_name'] = 'php5-fpm'
  res['apache2ctl'] = '/usr/sbin/apache2ctl'
  res
end

def family_value(str)
  if os[:family] == 'redhat'
    redhat_family_values[str]
  else
    debian_family_values[str]
  end
end

def docroot
  family_value('docroot')
end

def apache_service_name
  family_value('apache_service_name')
end

def fpm_service_name
  family_value('fpm_service_name')
end

def apache2ctl
  family_value('apache2ctl')
end

shared_examples_for 'php55 under apache' do |args|
  describe command('wget -qO- localhost:8080/phpinfo.php') do
    index_php_path = "#{docroot}/phpinfo.php"
    before do
      File.open(index_php_path, 'w') { |file| file.write('<?php phpinfo(); ?>') }
    end
    its(:stdout) { should match(/PHP Version 5.5/) }
  end
end

shared_examples_for 'php54 under apache' do |args|
  describe command('wget -qO- localhost:8080/phpinfo.php') do
    index_php_path = "#{docroot}/phpinfo.php"
    before do
      File.open(index_php_path, 'w') { |file| file.write('<?php phpinfo(); ?>') }
    end
    its(:stdout) { should match(/PHP Version 5.4/) }
  end
end

shared_examples_for 'magento under apache' do |args|
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
    phpinfo = %w(
      FPM\/FastCGI
      opcache.enable<\/td><td class="v">On
      opcache.memory_consumption<\/td><td class="v">256
      opcache.interned_strings_buffer<\/td><td class="v">8
      opcache.max_accelerated_files<\/td><td class="v">4000
      opcache.fast_shutdown<\/td><td class="v">1
      opcache.validate_timestamps<\/td><td class="v">Off
      memory_limit<\/td><td class="v">512M
      max_execution_time<\/td><td class="v">1800
      realpath_cache_size<\/td><td class="v">256k
      realpath_cache_ttl<\/td><td class="v">7200
      open_basedir<\/td><td class="v">no value
      session.entropy_length<\/td><td class="v">32
      session.entropy_file<\/td><td class="v">/dev/urandom
    )
    phpinfo.each do |line|
      its(:stdout) { should match(/#{line}/) }
    end

    its(:stdout) { should match(/PHP Version 5.(4|5)/) }
  end

  ## use http://www.magentocommerce.com/knowledge-base/entry/how-do-i-know-if-my-server-is-compatible-with-magento
  describe command('wget -qO- localhost:8080/magento-check.php') do
    before do
      File.open("#{docroot}/magento-check.php", 'w') { |file| file.write(File.read("#{ENV['BUSSER_ROOT']}/suites/serverspec/fixtures/magento-check.php")) }
    end
    its(:stdout) { should match(/Congratulations/) }
  end
end
