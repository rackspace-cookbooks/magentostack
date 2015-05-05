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
                       'magentostack::magento_configure',
                       'magentostack::nfs_server',
                       'magentostack::nfs_client')
        end

        it 'includes mysql-multi::_find_master' do
          expect(chef_run).to include_recipe('mysql-multi::_find_master')
        end

        it 'gets magento and extract it' do
          expect(chef_run).to put_ark('magento').with(action: [:put], url: 'http://www.magentocommerce.com/downloads/assets/1.9.1.1/magento-1.9.1.1.tar.gz')
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

        it 'should manage the nfs media directory and link it' do
          %w(/export/data/magento_media /mnt/magento_media).each do |dir|
            expect(chef_run).to create_directory(dir)
          end
        end

        it 'should create nfs export' do
          expect(chef_run).to create_nfs_export('/export/data/magento_media')
        end

        # has :action none and we can't step into the ruby
        it 'should delete original directory' do
          expect(chef_run).to_not delete_directory('/var/www/html/magento/media')
        end

        it 'should create symlink' do
          expect(chef_run).to create_link('/var/www/html/magento/media')
        end

        it 'should mount and enable the nfs export' do
          expect(chef_run).to mount_mount('/mnt/magento_media')
          expect(chef_run).to enable_mount('/mnt/magento_media')
        end
      end
    end
  end
end
