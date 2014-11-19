# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: redis_cache_discovery
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

# The goal of this recipe is to find all redis instances in the scope of the
# cookbook (see query below). The sentinel or slave recipes will use this data
# to figure out where the masters are (sentinel) or replicate from (slaves).
#
# By the time this recipe exits, it should have warned about chef solo, or set
# node.run_state['magentostack_redis_discovery']
#
# By default, it tries to just use the preset node['magentostack']['redis']['discovery'].
# If that preset isn't available, under chef solo, it warns and finishes.
# Otherwise, it does a search using node['magentostack']['redis']['discovery_query'].

include_recipe 'chef-sugar'

# see if the configuration specified some hard coded values
preset_nodes = node.deep_fetch('magentostack', 'redis', 'discovery')

# use preset if it exists
if preset_nodes
  Chef::Log.info("Redis server discovery was already set to #{preset_nodes}")
  node.run_state['magentostack_redis_discovery'] = preset_nodes

# if solo, just warn
elsif Chef::Config[:solo]
  Chef::Log.warn('redis_cache_find recipe uses search if node[\'magentostack\'][\'redis\'][\'discovery\']  attribute is not set.')
  Chef::Log.warn('Chef Solo does not support search.')

# otherwise, do the search we want to discover other redis nodes
else
  redis_nodes = search('node', node['magentostack']['redis']['discovery_query'])

  if redis_nodes.nil? || redis_nodes.count < 1
    errmsg = 'Did not find any redis nodes in discovery, but none were set'
    Chef::Log.warn(errmsg)
    redis_nodes = [] # so loop below exits
  end

  discovered_nodes = {}
  redis_nodes.each do |n|
    if n['magentostack'] && n['magentostack']['redis'] && n['magentostack']['redis']['servers']
      n['magentostack']['redis']['servers'].each do |redis_name, redis_instance|
        discovered_nodes[redis_name] = redis_instance
      end
    else
      Chef::Log.warn("Found node #{n.name} but didn't see any data under its ['magentostack']['redis']['servers'] attribute")
    end
  end

  # don't populate with empty hash
  if !discovered_nodes.empty?
    node.run_state['magentostack_redis_discovery'] = discovered_nodes
  end

end
