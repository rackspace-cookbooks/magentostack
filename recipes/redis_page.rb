# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: redis_page
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

# required by libraries/util.rb
include_recipe 'chef-sugar'

bind_port = node['magentostack']['redis']['bind_port_page']
server_name = "#{bind_port}-page-master"
node.set['magentostack']['redis']['servers'][server_name] = {
  'name' => server_name,
  'port' => bind_port,
  'requirepass' => MagentostackUtil.redis_page_password(node)
}
tag('magentostack_redis')
tag('magentostack_redis_page')
MagentostackUtil.recompute_redis(node)
