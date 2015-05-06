# Encoding: utf-8

require_relative 'spec_helper'

describe 'magentostack::magento_admin' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version, file_cache_path: '/tmp/chefspec/var/chef/cache') do |node|
            node_resources(node) # stub this node

            # Stub the node and any calls to Environment.Load to return this environment
            env = Chef::Environment.new
            env.name 'chefspec' # matches ./test/integration/
            allow(node).to receive(:chef_environment).and_return(env.name)
            allow(Chef::Environment).to receive(:load).and_return(env)
          end.converge(described_recipe)
        end
        it 'creates redis clean magento cronjob' do
          expect(chef_run).to install_yum_package('git')
          expect(chef_run).to checkout_git('/root/cm_redis_tools')
          expect(chef_run).to create_cron('redis_tag_cleanup').with(action: [:create])
        end
        it 'creates normal magento cronjob and set permissions on cron.sh' do
          expect(chef_run).to touch_file('/var/www/html/magento/cron.sh').with(mode: '755')
          expect(chef_run).to create_cron('magento_cron').with(minute: '*/5', user: 'apache', command: '/var/www/html/magento/cron.sh', action: [:create])
        end
      end
    end
  end
end
