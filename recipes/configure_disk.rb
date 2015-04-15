# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: format_disk
#
# Copyright 2014, Rackspace, US Inc.
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# partition /dev/xvdb
include_recipe 'parted'
parted_disk node['disk']['device'] do
  label_type 'gpt'
  part_type 'primary'
  action [:mklabel, :mkpart]
end
node.set['disk']['name'] = "#{node['disk']['device']}1"

# filesystem for /dev/xvdb1
include_recipe 'stack_commons::format_disk' # ~RACK002

# create mount dir /export/data
directory node['magentostack']['disk']['mount_point'] do
  user 'root'
  mode '0755'
  recursive true
  action :create
end

# mount /export/data
mount node['magentostack']['disk']['mount_point'] do
  device "#{node['disk']['device']}1"
  fstype node['disk']['fs']
  action [:mount, :enable]
end

node.set['elasticsearch']['path']['data'] = "#{node['magentostack']['disk']['mount_point']}/elasticsearch"
