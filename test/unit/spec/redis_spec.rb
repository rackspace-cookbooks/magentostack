# Encoding: utf-8

require_relative 'spec_helper'

describe 'magentostack all in one demo' do
  recipes_for_demo = %w(
    redis_single
    redis_single_slave
    redis_sentinel
    redis_configure).map { |r| "magentostack::#{r}" }

  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::ServerRunner.new(platform: platform, version: version) do |node, server|
            node_resources(node) # stub this node
            stub_nodes(platform, version, server) # stub other nodes for chef-zero
            stub_environments(server)

            # Stub the node and any calls to Environment.Load to return this environment
            env = Chef::Environment.new
            env.name 'chefspec' # matches ./test/integration/
            allow(node).to receive(:chef_environment).and_return(env.name)
            allow(Chef::Environment).to receive(:load).and_return(env)
          end.converge(*recipes_for_demo) # *splat operator for array to vararg
        end

        property = load_platform_properties(platform: platform, platform_version: version)
        property.to_s # pacify rubocop

        it 'should include redisio recipes' do
          %w(
            redisio::install
            redisio::configure
            redisio::enable
            redisio::sentinel
            redisio::sentinel_enable
          ).each do |recipe|
            expect(chef_run).to include_recipe(recipe)
          end
        end

        it 'should generate appropriate rackspace_iptables calls' do
          node = chef_run.node
          ipt = node['rackspace_iptables']['config']['chains']['INPUT']

          expect(ipt['-m tcp -p tcp -s 10.0.0.2 --dport 6379 -j ACCEPT']).to be_truthy
        end
      end
    end
  end
end

describe 'magentostack expanded all-in-one' do
  recipes_for_demo = %w(
    redis_object
    redis_object_slave
    redis_page
    redis_page_slave
    redis_session
    redis_session_slave
    redis_sentinel
    redis_configure).map { |r| "magentostack::#{r}" }

  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::ServerRunner.new(platform: platform, version: version) do |node, server|
            node_resources(node) # stub this node
            stub_nodes(platform, version, server) # stub other nodes for chef-zero
            stub_environments(server)

            # Stub the node and any calls to Environment.Load to return this environment
            env = Chef::Environment.new
            env.name 'chefspec' # matches ./test/integration/
            allow(node).to receive(:chef_environment).and_return(env.name)
            allow(Chef::Environment).to receive(:load).and_return(env)
          end.converge(*recipes_for_demo) # *splat operator for array to vararg
        end

        property = load_platform_properties(platform: platform, platform_version: version)
        property.to_s # pacify rubocop

        it 'should include redisio recipes' do
          %w(
            redisio::install
            redisio::configure
            redisio::enable
            redisio::sentinel
            redisio::sentinel_enable
          ).each do |recipe|
            expect(chef_run).to include_recipe(recipe)
          end
        end

        it 'should generate appropriate rackspace_iptables calls' do
          node = chef_run.node
          ipt = node['rackspace_iptables']['config']['chains']['INPUT']

          expect(ipt['-m tcp -p tcp -s 10.0.0.2 --dport 6381 -j ACCEPT']).to be_truthy
          expect(ipt['-m tcp -p tcp -s 10.0.0.2 --dport 6383 -j ACCEPT']).to be_truthy
          expect(ipt['-m tcp -p tcp -s 10.0.0.2 --dport 6385 -j ACCEPT']).to be_truthy
        end
      end
    end
  end
end
