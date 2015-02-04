# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: partition_nfs_disk
#
# Copyright 2015, Rackspace, US Inc.
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

parted_disk node['disk']['device'] do
  label_type 'gpt'
  part_type 'primary'
  action [:mklabel, :mkpart]
end

node.set['disk']['name'] = "#{node['magentostack']['nfs_server']['disk']['device']}1"

include_recipe 'magentostack::format_disk'

export_directory = node['magentostack']['nfs_server']['export_root']
export_name = node['magentostack']['nfs_server']['export_name']

directory "#{export_directory}/#{export_name}"

mount "#{export_directory}/#{export_name}" do
  device "#{node['disk']['device']}1"
  fstype node['disk']['fs']
  action [:mount, :enable]
end
