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
configure_method = node['magentostack']['configure_method']
case configure_method
when 'installer'

  # 'installer' - run installer script with provided values
  include_recipe 'magentostack::_magento_installer'

  # then do the template behavior! it won't overwrite the local.xml from the installer
  include_recipe 'magentostack::_magento_localxml'

when 'template'

  # 'template' - copy local.xml from local.xml.template
  include_recipe 'magentostack::_magento_localxml'

when 'none'
  Chef::Log.info('Magento configure method none was requested, not configuring magento')
else
  raise "You have specified to configure magento with method #{configure_method}, which is not valid."
end
