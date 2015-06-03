# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: magento_install
#
# Copyright 2014, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'chef-sugar'

# ensure they asked for a valid install method
install_method = node['magentostack']['install_method']

case install_method
when 'cloudfiles'
  # these can be populated in a wrapper using a data bag and then placed in node.run_state
  # or simply populated via environment, role, or node attributes
  rackspace_username = node.run_state['rackspace_cloud_credentials_username'] || node.deep_fetch('rackspace', 'cloud_credentials', 'username')
  rackspace_api_key = node.run_state['rackspace_cloud_credentials_api_key'] || node.deep_fetch('rackspace', 'cloud_credentials', 'api_key')
  download_file = node['magentostack']['download_file']

  # install these for nokogiri for xml for fog gem for rackspacecloud
  include_recipe 'build-essential'
  include_recipe 'rackspacecloud'

  # this will fail to be created as a resource, even when not being used, if
  # rackspace_username or rackspace_api_key are nil, so we guard it in a big if.
  rackspacecloud_file "#{Chef::Config[:file_cache_path]}/#{download_file}" do
    directory node['magentostack']['download_dir']
    rackspace_username rackspace_username
    rackspace_api_key rackspace_api_key
    rackspace_region node['magentostack']['download_region']
    binmode true
    action :create
  end

  ark 'magento' do
    url "file://#{Chef::Config[:file_cache_path]}/#{download_file}"
    path node['apache']['docroot_dir']
    owner node['apache']['user']
    group node['apache']['group']
    checksum node['magentostack']['checksum']
    action :put
  end
when 'ark'
  ark 'magento' do
    url node['magentostack']['download_url']
    path node['apache']['docroot_dir']
    owner node['apache']['user']
    group node['apache']['group']
    checksum node['magentostack']['checksum']
    action :put
  end
when 'git'
  include_recipe 'git'
  require 'base64'

  # Store deploy key in the chef file cache path, so it is outside of docroot
  id_deploy = "#{Chef::Config[:file_cache_path]}/id_deploy"
  deploy_key = MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'git_deploykey')
  fail 'deploy key could not be found' unless deploy_key
  deploy_key = Base64.decode64(deploy_key)

  # Write the actual keyfile
  file id_deploy do
    owner node['apache']['user']
    group node['apache']['group']
    mode '0600'
    content deploy_key
  end

  # need to determine apache's homedir, but we need to do it at convergence, not compile
  # since the user may not exist yet when the chef run is in the compile phase
  ruby_block 'evaluate apache homedir' do
    block do
      apache_ssh_dir = run_context.resource_collection.find(directory: 'apache .ssh')
      apache_ssh_dir.path File.expand_path("~#{node['apache']['user']}")
    end
  end

  # /var/www is owned by root, even though it's the home directory for the apache user
  directory 'apache .ssh' do
    owner node['apache']['user']
    group node['apache']['group']
    mode '0700'
  end

  # Write an SSH wrapper for git checkouts
  git_ssh_wrapper = "#{Chef::Config[:file_cache_path]}/git_ssh_wrapper.sh"
  template git_ssh_wrapper do
    user node['apache']['user']
    group node['apache']['group']
    mode '0700'
    variables(keyfile: id_deploy)
  end

  # Run the checkout into /var/www/html/magento
  magento_dir = "#{node['apache']['docroot_dir']}/magento"
  git magento_dir do
    repository node['magentostack']['git_repository']
    revision node['magentostack']['git_revision']
    ssh_wrapper git_ssh_wrapper
    action :sync
    enable_submodules true if node['magentostack']['git_submodules']
    user node['apache']['user']
    group node['apache']['group']
  end
when 'none'
  Chef::Log.info('Magento install method none was requested, not installing magento')
else
  fail "You have specified to install magento with method #{install_method}, which is not valid."
end

# required for stack_commons::mysql_base to find the app nodes
tag('magento_app_node')
node.save unless Chef::Config[:solo] # make me searchable right away!
