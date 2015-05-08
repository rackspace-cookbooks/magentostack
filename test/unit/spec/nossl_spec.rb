# Encoding: utf-8

require_relative 'spec_helper'

describe 'magentostack::apache-fpm' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version, log_level: :fatal) do |node|
            node_resources(node) # stub this node

            # Stub the node and any calls to Environment.Load to return this environment
            env = Chef::Environment.new
            env.name 'chefspec' # matches ./test/integration/
            allow(node).to receive(:chef_environment).and_return(env.name)
            allow(Chef::Environment).to receive(:load).and_return(env)

            # no ssl specific stuff
            node.set['magentostack']['web']['ssl'] = false
          end.converge(described_recipe) # *splat operator for array to vararg
        end

        property = load_platform_properties(platform: platform, platform_version: version)
        property.to_s # pacify rubocop

        it 'should not include apache2::mod_ssl or create SSL config file or keypair files' do
          expect(chef_run).to_not include_recipe('apache2::mod_ssl')
          expect(chef_run).to_not run_execute('a2enmod ssl')
          expect(chef_run).to_not create_certificate_manage('magento ssl certificate')
          expect(chef_run).to_not render_file('/etc/httpd/sites-available/magento_ssl_vhost.conf')
        end
      end
    end
  end
end
