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

found_clients = []
override_allow = node['magentostack']['redis']['override_allow']

if override_allow || Chef::Config[:solo]
  override_allow.each do |ip|
    found_clients << ip
  end
else
  found_clients = partial_search(:node, 'tags:magento_app_node',
                                 keys: {
                                   'name' => ['name'],
                                   'ip' => ['ipaddress'],
                                   'cloud' => ['provider', 'local_ipv4', 'public_ipv4']
                                 }
  ).map { |n| best_ip_for(n) }
end

found_clients.each do |node|
  MagentostackUtil.build_iptables(node) do |type, str, pri, comment|
    add_iptables_rule(type, str, pri, comment)
  end
end
