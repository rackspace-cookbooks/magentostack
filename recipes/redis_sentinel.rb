# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: redis_sentinel
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

# find a master to watch
master_name, master_ip, master_port = nil, nil, nil

session_master_name, session_master_ip, session_master_port = MagentostackUtil.redis_find_masters(node) do |name, data|
  name.include?('-session-master') && !name.include?('slave')
end
single_master_name, single_master_ip, single_master_port = MagentostackUtil.redis_find_masters(node) do |name, data|
  name.include?('-single-master') && !name.include?('slave')
end

# prefer session master over single master, for sentinel monitoring
if session_master_name && session_master_ip && session_master_port
  master_name, master_ip, master_port = session_master_name, session_master_ip, session_master_port
elsif single_master_name && single_master_ip && single_master_port
  master_name, master_ip, master_port = single_master_name, single_master_ip, single_master_port
else
  Chef::Log.warn('Did not find any single master or session master redis instances to monitor with sentinel, not proceeding')
  return
end

Chef::Log.info("Choosing this sentinel's master to be #{master_name} (#{master_ip}:#{master_port}) ")
bind_port = node['magentostack']['redis']['bind_port_sentinel']
server_name = "#{bind_port}-sentinel"
node.set['magentostack']['redis']['sentinels'][server_name] = {
  'name' => server_name,
  'sentinel_port' => bind_port,
  'master_ip' => master_ip,
  'master_port' => master_port
}
tag('magentostack_redis')
tag('magentostack_redis_sentinel')
MagentostackUtil.recompute_redis(node, 'sentinels')
