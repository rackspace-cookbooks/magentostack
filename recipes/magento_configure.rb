# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: magento_configure
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

include_recipe 'chef-sugar'

include_recipe 'magentostack::_magento_installprep' # prepare variables

# figure out how to create local.xml
if node['magentostack']['configure_method']
  # 'template' - copy local.xml from local.xml.template
  # 'installer' - run installer script
  include_recipe "magentostack::_magento_localxml_#{node['magentostack']['configure_method']}"
else
  Chef::Log.warn("Configuration method was #{node['magentostack']['configure_method']}, not configuring. local.xml may not exist.")
end

# things below this point need an existing local.xml
include_recipe 'magentostack::_magento_mysql' # enable persistent connections to mysql
include_recipe 'magentostack::_magento_redis' # enable redis caching
