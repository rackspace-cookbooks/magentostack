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

# enable full page cache for testing
template "#{node['magentostack']['web']['dir']}/enable-magento-fpc.php" do
  source 'magento/enable-magento-fpc.php.erb'
  user node['magentostack']['web']['user']
  group node['magentostack']['web']['group']
  mode '0700'
end

execute 'php enable-magento-fpc.php' do
  cwd node['magentostack']['web']['dir']
  user node['magentostack']['web']['user']
  group node['magentostack']['web']['group']
end
