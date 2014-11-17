require_relative 'spec_helper'

describe 'magentostack::mysql' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do

        context 'for mysql_base' do
          let(:chef_run) do
            ChefSpec::ServerRunner.new(platform: platform, version: version, log_level: ::LOG_LEVEL) do |node, server|
              node_resources(node)
            end.converge('magentostack::mysql_base')
          end

          it 'includes stack_commons recipe' do
            expect(chef_run).to include_recipe('stack_commons::mysql_base')
          end
        end

        context 'for mysql_master' do
          let(:chef_run) do
            ChefSpec::ServerRunner.new(platform: platform, version: version, log_level: ::LOG_LEVEL) do |node, server|
              node_resources(node)
            end.converge('magentostack::mysql_master')
          end

          it 'includes stack_commons recipe' do
            expect(chef_run).to include_recipe('stack_commons::mysql_master')
          end
        end

        context 'for mysql_slave' do
          let(:chef_run) do
            ChefSpec::ServerRunner.new(platform: platform, version: version, log_level: ::LOG_LEVEL) do |node, server|
              stub_nodes(platform, version, server)
              node_resources(node)
            end.converge('magentostack::mysql_slave')
          end

          it 'includes stack_commons recipe' do
            expect(chef_run).to include_recipe('stack_commons::mysql_slave')
          end
        end

        context 'for mysql_holland' do
          let(:chef_run) do
            ChefSpec::ServerRunner.new(platform: platform, version: version, log_level: ::LOG_LEVEL) do |node, server|
              node_resources(node)
            end.converge('magentostack::mysql_holland')
          end

          it 'includes stack_commons recipe' do
            expect(chef_run).to include_recipe('stack_commons::mysql_holland')
          end
        end

        context 'for mysql_add_drive' do
          let(:chef_run) do
            ChefSpec::ServerRunner.new(platform: platform, version: version, log_level: ::LOG_LEVEL) do |node, server|
              node_resources(node)
            end.converge('magentostack::mysql_add_drive')
          end

          it 'includes stack_commons recipe' do
            expect(chef_run).to include_recipe('stack_commons::mysql_add_drive')
          end
        end

      end
    end
  end
end
