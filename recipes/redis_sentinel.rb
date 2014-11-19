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
include_recipe 'magentostack::redis_discovery'

# find redis instances in the same chef environment
found_instances = node.run_state['magentostack_redis_discovery']
if found_instances && !found_instances.empty?
  Chef::Log.debug("Sentinel discovery found the following instances: #{found_instances.keys.join(',')}")
else
  Chef::Log.warn('Sentinel discovery not find any redis instances to monitor with sentinel, not proceeding')
  return
end

master_name = nil
master_ip = nil
master_port = nil

# look for a single master instance, that is our 2nd priority if we don't find a session instance
single_masters = found_instances.select { |name, data| name.include?('-single-master') }
if single_masters && !single_masters.empty?
  if single_masters.count > 1
    Chef::Log.warn("Sentinel discovery found more than one single master redis instance using query \'#{node['magentostack']['redis']['discovery_query']}\': #{single_masters.keys.join(',')}")
  else
    Chef::Log.debug("Found #{single_masters.count} single masters: #{single_masters.keys.join(',')}")
  end
  master_name, master_data = single_masters.first
  master_ip = MagentostackUtil.get_ip_by_name(master_name, node)
  master_port = master_data['port']
end

# look for a session store instance, that is our top priority for sentinel
session_masters = found_instances.select { |name, data| name.include?('-session-master') }
if session_masters && !session_masters.empty?
  if session_masters.count > 1
    Chef::Log.warn("Sentinel discovery found more than one session store master redis instance using query \'#{node['magentostack']['redis']['discovery_query']}\': #{single_masters.keys.join(',')}")
  else
    Chef::Log.debug("Found #{session_masters.count} session masters: #{session_masters.keys.join(',')}")
  end
  master_name, master_data = session_masters.first
  master_ip = MagentostackUtil.get_ip_by_name(master_name, node)
  master_port = master_data['port']
end

if master_name && master_ip && master_port
  Chef::Log.info("Choosing this sentinel's master to be #{master_name} (#{master_ip}:#{master_port}) ")
else
  Chef::Log.warn('Did not find any single master or session master redis instances to monitor with sentinel, not proceeding')
  return
end

bind_port = node['magentostack']['redis']['bind_port_sentinel']
server_name = "#{bind_port}-sentinel"
node.set['magentostack']['redis']['sentinels'][server_name] = {
  'name' => server_name,
  'sentinel_port' => bind_port,
  'master_ip' => master_ip,
  'master_port' => master_port
}
MagentostackUtil.recompute_redis(node, 'sentinels')
tag('magentostack_redis')
tag('magentostack_redis_sentinel')
