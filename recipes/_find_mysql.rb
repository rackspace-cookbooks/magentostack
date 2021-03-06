# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: _find_mysql
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
  # will return this already if set: node['mysql-multi']['master']
  include_recipe 'mysql-multi::_find_master'

  node.default['magentostack']['config']['db']['host'] = MagentostackUtil.construct_mysql_url(node['mysql-multi']['master'], node['mysql']['port'])
  Chef::Log.info("magentostack::_find_mysql selected #{node['mysql-multi']['master']}:#{node['mysql']['port']} as the mysql master connect string")
rescue
  Chef::Log.warn('magentostack::_find_mysql did not find a mysql master to use for magento. You may need to reconverge.')
end
