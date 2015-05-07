# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Attributes:: redis
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

# don't let redisio setup for us, empty instances as default
override['redisio']['bypass_setup'] = true
# (nil makes redisio create default instances, empty array does not)
default['redisio']['servers'] = []
default['redisio']['sentinels'] = []

# for a single instance, this is the bind port
default['magentostack']['redis']['bind_port_single'] = '6379'
default['magentostack']['redis']['bind_port_single_slave'] = '6380'

# for a separate session cache instance, this is the bind port
default['magentostack']['redis']['bind_port_session'] = '6381'
default['magentostack']['redis']['bind_port_session_slave'] = '6382'

# for a separate object cache instance, this is the bind port
default['magentostack']['redis']['bind_port_object'] = '6383'
default['magentostack']['redis']['bind_port_object_slave'] = '6384'

# for a separate full page cache instance, this is the bind port
default['magentostack']['redis']['bind_port_page'] = '6385'
default['magentostack']['redis']['bind_port_page_slave'] = '6386'

# for sentinel instances to use as a bind port
default['magentostack']['redis']['bind_port_sentinel'] = '46379'

# search query for discovery
default['magentostack']['redis']['discovery_query'] = "tags:magentostack_redis AND chef_environment:#{node.chef_environment}"

# overrides for chef-solo, other dependency injection
# default['magentostack']['redis']['override_page_name'] = 'example01'
# default['magentostack']['redis']['override_page_host'] = 'localhost'
# default['magentostack']['redis']['override_page_port'] = '123'
# default['magentostack']['redis']['override_session_name'] = 'example01'
# default['magentostack']['redis']['override_session_host'] = 'localhost'
# default['magentostack']['redis']['override_session_port'] = '123'
# default['magentostack']['redis']['override_object_name'] = 'example01'
# default['magentostack']['redis']['override_object_host'] = 'localhost'
# default['magentostack']['redis']['override_object_port'] = '123'
