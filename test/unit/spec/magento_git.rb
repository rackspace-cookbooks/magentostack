# Encoding: utf-8

require_relative 'spec_helper'

describe 'magentostack::magento enterprise with git install' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
            node_resources(node) # stub this node

            node.set['rackspace']['cloud_credentials']['username'] = 'foo'
            node.set['rackspace']['cloud_credentials']['api_key'] = 'bar'

            node.set['magentostack']['flavor'] = 'enterprise'
            node.set['magentostack']['install_method'] = 'git'

            node.set['magentostack']['git_repository'] = 'git@github.com:org/repo.git'
            node.set['magentostack']['git_revision'] = 'master'
            node.set['magentostack']['git_deploykey'] = 'Zm9vCg=='

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

        it 'gets magento and extract it' do
          expect(chef_run).to sync_git('/var/www/html/magento')
        end
      end
    end
  end
end
