# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: _magento_installprep
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

# Install preparation involves lots of variable calculation, most of which is
# then placed in `node.run_state['magentostack_installer_...']`

# flag for an installer or setup having been done already
node.run_state['magentostack_installer_magento_configured_file'] = "#{node['magentostack']['web']['dir']}/.magento_configured"

# determine plain URL
node.default['magentostack']['config']['url'] =
  MagentostackUtil.construct_url(
    node['magentostack']['web']['domain'],
    node['magentostack']['web']['http_port'],
    'http'
  )

# determine URL with SSL enabled
node.default['magentostack']['config']['secure_base_url'] =
  MagentostackUtil.construct_url(
    node['magentostack']['web']['domain'],
    node['magentostack']['web']['https_port'],
    'https'
  )

# Configure all the database things
include_recipe 'magentostack::_find_mysql' # let us search for a database

if node.run_state['magentostack_installer_database_name']
  dbname = node.run_state['magentostack_installer_database_name']
else
  dbname = node['magentostack']['mysql']['databases'].keys[0]
end
node.run_state['magentostack_installer_database_name'] = dbname # for installer
node.default['magentostack']['config']['db']['dbname'] = dbname # for local.xml

# port is included here. thanks rubocop for complaining about the lines below being too long.
unless node.run_state['magentostack_installer_database_host']
  node.run_state['magentostack_installer_database_host'] = node['magentostack']['config']['db']['host']
end
unless node.run_state['magentostack_installer_database_user']
  node.run_state['magentostack_installer_database_user'] = node['magentostack']['mysql']['databases'][dbname]['mysql_user']
end
unless node.run_state['magentostack_installer_database_pass']
  node.run_state['magentostack_installer_database_pass'] = node['magentostack']['mysql']['databases'][dbname]['mysql_password']
end

# unless we override through chef attributes or node.run_state, default to the username and password used for the installer
node.default['magentostack']['config']['db']['username'] = node.run_state['magentostack_installer_database_user']
node.default['magentostack']['config']['db']['password'] = node.run_state['magentostack_installer_database_pass']
