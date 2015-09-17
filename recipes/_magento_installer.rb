# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: _magento_localxml_installer
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

# Run install.php script for initial magento setup
# We must be sure we know all important configuration to pass to magento at this point

if node.run_state['magentostack_installer_database_host'].to_s == 'false'
  fail 'Could not find a database host for Magento'
end

# temporary location for script that runs install.php
setup_script = "#{Chef::Config[:file_cache_path]}/magentostack.sh"

template setup_script do
  source 'magentostack.sh.erb'
  user node['apache']['user']
  group node['apache']['group']
  mode '0700'
  variables(
    locale: MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'config', 'locale'),
    timezone: MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'config', 'tz'),
    default_currency: MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'config', 'default_currency'),
    db_host: MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'installer', 'database', 'host'),
    db_model: MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'config', 'db', 'model'),
    db_name: MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'installer', 'database', 'name'),
    db_user: MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'installer', 'database', 'user'),
    db_pass: MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'installer', 'database_pass'),
    db_prefix: MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'config', 'db', 'prefix'),
    session_save: MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'config', 'session', 'save'),
    magento_configured_file: MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'installer', 'magento', 'configured_file')
  )
end

template "#{node['magentostack']['web']['dir']}/check-magento-installed.php" do
  source 'magento/check-magento-installed.php.erb'
  user node['apache']['user']
  group node['apache']['group']
  mode '0700'
end

unless includes_recipe?('magentostack::magento_admin')
  execute 'wait_for_admin_to_start_config' do
    command 'sleep 60'
    not_if { File.exist?(node.run_state['magentostack_installer_magento_configured_file']) }
  end
end

execute setup_script do
  cwd node['magentostack']['web']['dir']
  user node['apache']['user']
  group node['apache']['group']
  not_if { File.exist?(node.run_state['magentostack_installer_magento_configured_file']) }
end
