# Encoding: utf-8

require_relative 'spec_helper'

describe 'magentostack::single_node' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::ServerRunner.new(platform: platform, version: version, log_level: ::LOG_LEVEL) do |node, server|
            node_resources(node)
          end.converge(described_recipe)
        end

        it 'should include single_node recipes' do
          %w(
            magentostack::redis_object
            magentostack::redis_object_slave
            magentostack::redis_page
            magentostack::redis_page_slave
            magentostack::redis_session
            magentostack::redis_session_slave
            magentostack::redis_sentinel
            magentostack::redis_configure
            magentostack::mysql_master
            magentostack::mysql_holland
            magentostack::apache-fpm
            magentostack::newrelic
            magentostack::magento
          ).each do |recipe|
            expect(chef_run).to include_recipe(recipe)
          end
        end
      end
    end
  end
end
