# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: _magento_cloudfiles
#
# Copyright 2014, Rackspace Hosting
#

# these can be populated in a wrapper using a data bag and then placed in node.run_state
# or simply populated via environment, role, or node attributes
rackspace_username = node.run_state['rackspace_cloud_credentials_username'] || node['rackspace']['cloud_credentials']['username']
rackspace_api_key = node.run_state['rackspace_cloud_credentials_api_key'] || node['rackspace']['cloud_credentials']['api_key']

rackspacecloud_file node['magentostack']['download_file'] do
  directory node['magentostack']['download_dir']
  rackspace_username rackspace_username
  rackspace_api_key rackspace_api_key
  rackspace_region node['magentostack']['download_region']
  binmode true
  checksum node['magentostack']['checksum']
  action :create
end

ark 'magento_cloudfiles' do
  url "file://#{Chef::Config[:file_cache_path]}/#{node['magentostack']['download_file']}"
  path node['apache']['docroot_dir']
  owner node['apache']['user']
  group node['apache']['group']
  checksum node['magentostack']['checksum']
  action :put
end
