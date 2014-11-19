# Encoding: utf-8

require_relative 'spec_helper'

describe 'magentostack::apache-fpm' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::ServerRunner.new(platform: platform, version: version, log_level: :fatal) do |node, server|
            node_resources(node) # stub this node
            stub_nodes(platform, version, server) # stub other nodes for chef-zero

            # Stub the node and any calls to Environment.Load to return this environment
            env = Chef::Environment.new
            env.name 'chefspec' # matches ./test/integration/
            allow(node).to receive(:chef_environment).and_return(env.name)
            allow(Chef::Environment).to receive(:load).and_return(env)

          end.converge(described_recipe) # *splat operator for array to vararg
        end

        property = load_platform_properties(platform: platform, platform_version: version)
        property.to_s # pacify rubocop

        shared_examples_for 'all platforms' do
          it 'includes apache2 recipe' do
            expect(chef_run).to include_recipe('apache2')
          end
          it 'includes apache2::mod_fastcgi recipe' do
            expect(chef_run).to include_recipe('apache2::mod_fastcgi')
          end
          it 'includes php-fpm recipe' do
            expect(chef_run).to include_recipe('php-fpm')
          end
          it 'configures apache with fastcgi' do
            expect(chef_run).to run_execute('a2enconf fastcgi.conf')
          end
        end

        shared_examples_for 'magento vhosts' do |vhost_path, platform_family|
          it 'configures a vhost for magento' do
            expect(chef_run).to render_file("#{vhost_path}/default.conf").with_content(fixture_files("magento_vhost_#{platform_family}"))
            expect(chef_run).to render_file("#{vhost_path}/ssl.conf").with_content(fixture_files("magento_vhost_ssl_#{platform_family}"))
          end
        end

        shared_examples_for 'fastcgi configuration' do |apache_config|
          it 'configures fastcgi' do
            expect(chef_run).to render_file("#{apache_config}/conf-available/fastcgi.conf").with_content(fixture_files('fastcgi'))
          end
        end

        shared_examples_for 'fastcgi patched version' do
          it 'gets the patched mod_fastcgi' do
            expect(chef_run).to create_remote_file('download fastcgi source').with(source: 'http://www.fastcgi.com/dist/mod_fastcgi-SNAP-0910052141.tar.gz')
          end
        end

        shared_examples_for 'apache modules' do
          it 'enables apache modules' do
            %w(
              status actions alias auth_basic
              authn_file authz_default
              authz_groupfile authz_host
              authz_user autoindex dir env mime
              negotiation setenvif ssl headers
              expires log_config logio
            ).each do |mod|
              expect(chef_run).to run_execute("a2enmod #{mod}")
            end
          end
        end

        case property[:platform_family]
        # CENTOS
        when 'rhel'
          it 'includes recipes (yum/yum-epel/yum-ius) to set up sources repositories' do
            expect(chef_run).to include_recipe('yum')
            expect(chef_run).to include_recipe('yum-epel')
            expect(chef_run).to include_recipe('yum-ius')
          end
          it_should_behave_like 'all platforms'
          it 'creates document root' do
            expect(chef_run).to create_directory('/var/www/html/magento')
          end
          it_should_behave_like 'apache modules'
          it_should_behave_like 'magento vhosts', '/etc/httpd/sites-available', property[:platform_family]
          it_should_behave_like 'fastcgi patched version'
          it_should_behave_like 'fastcgi configuration', '/etc/httpd'
        # UBUNTU
        when 'ubuntu'
          it 'includes recipes (apt) to set up sources repositories' do
            expect(chef_run).to include_recipe('apt')
          end
          it_should_behave_like 'all platforms'
          it 'creates document root' do
            expect(chef_run).to create_directory('/var/www/magento')
          end
          it_should_behave_like 'apache modules', '/etc/apache2'
          describe 'configures a vhost for magento' do
            it_should_behave_like 'magento vhosts', '/etc/apache2/sites-available', property[:platform_family]
          end
          # we test a different configuration for Apache 2.4
          if property[:platform_version] == '14.04'
            it 'configures fastcgi' do
              expect(chef_run).to render_file('/etc/apache2/conf-available/fastcgi.conf').with_content(fixture_files('fastcgi_apache2-4'))
            end
          else
            it_should_behave_like 'fastcgi configuration', '/etc/apache2'
          end
        end
      end
    end
  end
end
