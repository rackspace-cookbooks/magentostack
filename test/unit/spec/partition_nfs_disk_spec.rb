# Encoding: utf-8

require_relative 'spec_helper'

describe 'magentostack::configure_disk' do
  before { stub_resources }
  supported_platforms.each do |platform, versions|
    versions.each do |version|
      context "on #{platform.capitalize} #{version}" do
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version, log_level: ::LOG_LEVEL) do |node|
            node_resources(node)
          end.converge(described_recipe)
        end

        it 'partitions /dev/xvde' do
          expect(chef_run).to mklabel_parted_disk('/dev/xvde')
          expect(chef_run).to mkpart_parted_disk('/dev/xvde')
        end

        it 'includes recipes' do
          expect(chef_run).to include_recipe('stack_commons::format_disk')
        end

        it 'creates the directory /export/data' do
          expect(chef_run).to create_directory('/export/data')
        end

        it 'mounts and enables /export/magento_media' do
          expect(chef_run).to mount_mount('/export/data')
          expect(chef_run).to enable_mount('/export/data')
        end
      end
    end
  end
end
