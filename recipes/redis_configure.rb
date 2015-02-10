# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: redis_configure
#
# Copyright 2014 Rackspace, US Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# this recipe should be called after every other magentostack::redis_* recipe
# because the configure and enable recipes in redisio will complete the setup
# of all instances (redis and sentinel both)
%w(
  redisio::install
  redisio::configure
  redisio::enable
  redisio::sentinel
  redisio::sentinel_enable
).each do |recipe|
  include_recipe recipe
end

# figure out what clients should be allowed to connect
found_clients = []
override_allow = node['magentostack']['redis']['override_allow']

if override_allow || Chef::Config[:solo]
  override_allow.each do |ip|
    found_clients << ip
  end
else
  found_clients = search(:node, 'tags:magento_app_node')
end
found_clients.compact! # remove nil elements

# figure out the local redis instances
local_redis_instances = MagentostackUtil.redis_instance_info([node], node)
local_redis_instances.each do |instance_name, instance_config|
  next unless instance_config['port']
  dest_port = instance_config['port']

  # allow each client to connect to the redis instance
  found_clients.each do |other_node|
    other_node_ip = Chef::Sugar::IP.best_ip_for(node, other_node)
    comment = "Allow redis client from #{other_node.name}/#{instance_name}:#{dest_port}"
    add_iptables_rule('INPUT', "-m tcp -p tcp -s #{other_node_ip} --dport #{dest_port} -j ACCEPT", 9998, comment)
  end
end
