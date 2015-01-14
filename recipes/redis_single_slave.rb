# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: redis_single_slave
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

master_name, master_ip, master_port = MagentostackUtil.redis_find_masters(node) do |name, data|
  name.include?('-single-master') && !name.include?('slave')
end

unless master_name && master_ip && master_port
  Chef::Log.warn('magentostack::redis_single_slave did not find a redis single master to configure a redis slave, not proceeding')
  return
end

bind_port = node['magentostack']['redis']['bind_port_single_slave']
server_name = "#{bind_port}-single-slave"
node.set['magentostack']['redis']['servers'][server_name] = {
  'name' => server_name,
  'port' => bind_port,
  'requirepass' => MagentostackUtil.redis_single_password(node),
  'masterauth' => MagentostackUtil.redis_single_password(node),
  'slaveof' => { 'master_name' => master_name, 'address' => master_ip, 'port' => master_port }
}
tag('magentostack_redis')
tag('magentostack_redis_single_slave')
MagentostackUtil.recompute_redis(node)
