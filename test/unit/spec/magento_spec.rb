# Encoding: utf-8

require_relative 'spec_helper'

describe 'magentostack::magento recipes' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        cached(:chef_run) do
          ChefSpec::ServerRunner.new(platform: platform, version: version) do |node, server|
            node_resources(node) # stub this node
            stub_nodes(platform, version, server) # stub other nodes for chef-zero
            stub_environments(server)

            # Stub the node and any calls to Environment.Load to return this environment
            env = Chef::Environment.new
            env.name 'chefspec' # matches ./test/integration/
            allow(node).to receive(:chef_environment).and_return(env.name)
            allow(Chef::Environment).to receive(:load).and_return(env)
          end.converge('magentostack::magento_install',
                       'magentostack::redis_single',
                       'magentostack::_find_mysql',
                       'magentostack::magento_configure')
        end

        it 'includes mysql-multi::_find_master' do
          expect(chef_run).to include_recipe('mysql-multi::_find_master')
        end

        it 'gets magento and extract it' do
          expect(chef_run).to put_ark('magento').with(action: [:put], url: 'http://www.magentocommerce.com/downloads/assets/1.9.0.1/magento-1.9.0.1.tar.gz')
        end

        it 'runs Magento installer' do
          expect(chef_run).to create_cookbook_file('/var/www/html/magento/check-magento-installed.php')
          expect(chef_run).to create_template("#{Chef::Config[:file_cache_path]}/magentostack.sh")
          expect(chef_run).to run_execute("#{Chef::Config[:file_cache_path]}/magentostack.sh")
        end

        it 'performs local.xml and Cm_RedisSession.xml edits' do
          expect(chef_run).to replace_xml('enable redis in ./app/etc/modules/Cm_RedisSession.xml')
          expect(chef_run).to append_if_missing_xml('set session_store to db in ./app/etc/local.xml')
          expect(chef_run).to append_if_missing_xml('set session cache in ./app/etc/local.xml')
          expect(chef_run).to append_if_missing_xml('set object cache in ./app/etc/local.xml')
        end
      end
    end
  end
end
