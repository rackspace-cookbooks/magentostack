# Encoding: utf-8

require_relative 'spec_helper'

describe 'magentostack::magento recipes' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        cached(:chef_run) do
          ChefSpec::ServerRunner.new(platform: platform, version: version, file_cache_path: '/tmp/chefspec/var/chef/cache') do |node, server|
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
          expect(chef_run).to put_ark('magento').with(action: :put, url: 'http://www.magentocommerce.com/downloads/assets/1.9.1.1/magento-1.9.1.1.tar.gz')
        end

        it 'runs Magento installer' do
          expect(chef_run).to create_template('/var/www/html/magento/check-magento-installed.php')
          expect(chef_run).to create_template("#{Chef::Config[:file_cache_path]}/magentostack.sh")
          expect(chef_run).to run_execute("#{Chef::Config[:file_cache_path]}/magentostack.sh")
          expect(chef_run).to run_execute('wait_for_admin_to_start_config')
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
          expect(chef_run).to create_directory('/export/data')
          expect(chef_run).to create_nfs_export('/export/data/magento_media')
        end

        # has :action none and we can't step into the ruby
        it 'should delete original directory' do
          expect(chef_run).to run_ruby_block('check for magento media directory at converge time')
          expect(chef_run).to_not delete_directory('/var/www/html/magento/media')
        end

        it 'should create symlink' do
          expect(chef_run).to create_directory('/mnt/magento_media/media')
          expect(chef_run).to create_link('/var/www/html/magento/media')
        end

        it 'should mount and enable the nfs export' do
          expect(chef_run).to mount_mount('/mnt/magento_media')
          expect(chef_run).to enable_mount('/mnt/magento_media')
        end

        it 'should make app/etc/local.xml edits' do
          expect(chef_run).to create_remote_file_if_missing('copy local.xml.template to local.xml')
          expect(chef_run).to run_ruby_block('fail at runtime instant if missing local.xml.template')

          expect(chef_run).to replace_xml('add admin front name to local.xml')
          expect(chef_run).to append_if_missing_xml('add install date to local.xml')
          expect(chef_run).to replace_xml('add crypt key to local.xml')
          expect(chef_run).to replace_xml('add db prefix to local.xml')
          expect(chef_run).to_not append_if_missing_xml('add default_setup to local.xml')
          expect(chef_run).to_not append_if_missing_xml('add core_read to local.xml under config/global/resources')
          expect(chef_run).to_not append_if_missing_xml('add connection to local.xml under config/global/resources/core_read')
          expect(chef_run).to_not append_if_missing_xml('add use to local.xml under config/global/resources/core_read/connection')
          expect(chef_run).to_not append_if_missing_xml('add core_write to local.xml under config/global/resources')
          expect(chef_run).to_not append_if_missing_xml('add connection to local.xml under config/global/resources/core_write')
          expect(chef_run).to_not append_if_missing_xml('add use to local.xml under config/global/resources/core_write/connection')
          expect(chef_run).to remove_xml('remove core_read to local.xml')
          expect(chef_run).to remove_xml('remove core_write to local.xml')
          expect(chef_run).to append_if_missing_xml('add host to local.xml')
          expect(chef_run).to append_if_missing_xml('add username to local.xml')
          expect(chef_run).to append_if_missing_xml('add password to local.xml')
          expect(chef_run).to append_if_missing_xml('add dbname to local.xml')
          expect(chef_run).to append_if_missing_xml('add initStatements to local.xml')
          expect(chef_run).to append_if_missing_xml('add model to local.xml')
          expect(chef_run).to append_if_missing_xml('add type to local.xml')
          expect(chef_run).to append_if_missing_xml('add pdoType to local.xml')
          expect(chef_run).to append_if_missing_xml('add active to local.xml')
          expect(chef_run).to append_if_missing_xml('add persistent to local.xml')
        end
      end
    end
  end
end
