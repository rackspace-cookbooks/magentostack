# Encoding: utf-8

require_relative 'spec_helper'

describe 'magentostack::magento_admin' do
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
          end.converge(described_recipe)
        end
        it 'set the execute permission on cron.sh' do
          expect(chef_run).to touch_file('/var/www/html/magento/cron.sh').with(mode: '755')
        end
        it 'creates cronjob' do
          expect(chef_run).to create_cron('magento_cron').with(minute: '*/5', user: 'apache', command: '/var/www/html/magento/cron.sh', action: [:create])
        end
      end
    end
  end
end
