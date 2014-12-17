# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: magento
#
# Copyright 2014, Rackspace Hosting
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

# search for Mysql node
begin
  include_recipe 'mysql-multi::_find_master'
  node.default['magentostack']['config']['db']['host'] = node['mysql-multi']['master']
rescue
  Chef::Log.warn('Did not find a mysql master to use for magento. You may need to reconverge.')
end

# define computed attributes in the recipe
node.default['magentostack']['config']['db']['port'] = node['mysql']['port']
node.default['magentostack']['config']['url'] = "http://#{node['magentostack']['web']['domain']}/"
node.default['magentostack']['config']['secure_base_url'] = "https://#{node['magentostack']['web']['domain']}/"

# ensure they asked for a valid install method
install_method = node['magentostack']['install_method']
unless %w(ark cloudfiles none).include? install_method
  fail "You have specified to install magento with method #{install_method}, which is not valid."
end

include_recipe 'magentostack::_magento_ark' if node['magentostack']['install_method'] == 'ark'
include_recipe 'magentostack::_magento_cloudfiles' if node['magentostack']['install_method'] == 'cloudfiles'

# Run install.php script for initial magento setup
# Configure all the things
database_name = node['magentostack']['mysql']['databases'].keys[0]

# temporary location for script that runs install.php
setup_script = "#{Chef::Config[:file_cache_path]}/magentostack.sh"

# output of install.php goes into this file, needs to be writeable by apache
# but ensure it stays outside of the actual web-accessible dir ('docroot/magento')
magento_configured_file = "#{node['magentostack']['web']['dir']}/.magento_configured"

template setup_script do
  source 'magentostack.sh.erb'
  user node['apache']['user']
  group node['apache']['group']
  mode '0700'
  variables(
    database_name: database_name,
    magento_configured_file: magento_configured_file
    )
end

execute setup_script do
  cwd node['magentostack']['web']['dir']
  user node['apache']['user']
  group node['apache']['group']
  not_if { File.exist?(magento_configured_file) }
end

include_recipe 'magentostack::_magento_redis'

# required for stack_commons::mysql_base to find the app nodes
tag('magento_app_node')
