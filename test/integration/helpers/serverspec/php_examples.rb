shared_examples_for 'php55 under apache' do |args|
  describe command('wget -qO- localhost:8080/phpinfo.php') do
    index_php_path = "#{docroot}/phpinfo.php"
    before do
      File.open(index_php_path, 'w') { |file| file.write('<?php phpinfo(); ?>') }
    end
    its(:stdout) { should match(/PHP Version 5.5/) }
  end

  it_behaves_like 'php under apache'
end

shared_examples_for 'php54 under apache' do |args|
  describe command('wget -qO- localhost:8080/phpinfo.php') do
    index_php_path = "#{docroot}/phpinfo.php"
    before do
      File.open(index_php_path, 'w') { |file| file.write('<?php phpinfo(); ?>') }
    end
    its(:stdout) { should match(/PHP Version 5.4/) }
  end

  it_behaves_like 'php under apache'
end

shared_examples_for 'php under apache' do |args|
  describe service(fpm_service_name) do
    it { should be_enabled }
    it { should be_running }
  end

  describe command('php -v') do
    its(:stdout) { should match(/with Zend OPcache/) }
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
end
