# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: nfs_server
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

include_recipe 'chef-sugar'
include_recipe 'nfs::server' # ~RACK002

found_clients = []
override_allow = node['magentostack']['nfs_server']['override_allow']

if override_allow
  override_allow.each do |ip|
    found_clients << ip
  end
elsif Chef::Config[:solo]
  Chef::Log.warn('You are using chef-solo, but have no overridden the nfs server search for clients')
else
  client_search_results = search(:node, "chef_environment:#{node.chef_environment}")
  found_clients = client_search_results.map { |n| best_ip_for(n) }.compact
end

Chef::Log.warn('Did not find any clients to permit on NFS export of media') unless found_clients && !found_clients.empty?

# self-ip or localhost
self_ip = best_ip_for(node) || '127.0.0.1'
found_clients << self_ip

export_directory = node['magentostack']['nfs_server']['export_root']
directory export_directory do
  user 'root'
  mode '0755'
  recursive true
end

export_name = node['magentostack']['nfs_server']['export_name']
export_full_path = "#{export_directory}/#{export_name}"
directory export_full_path do
  user 'root'
  mode '0755'
  recursive true
end

nfs_export export_full_path do
  network found_clients.compact # remove nil
  writeable true
  sync true
  options ['no_root_squash', 'sec=sys']
end

# Open iptables
include_recipe 'platformstack::iptables'
found_clients.each do |other_node_ip|
  add_iptables_rule('INPUT', "-m tcp -p tcp -s #{other_node_ip} --dport 111 -j ACCEPT", 200, 'Allow access to NFS')
  add_iptables_rule('INPUT', "-m udp -p udp -s #{other_node_ip} --dport 111 -j ACCEPT", 200, 'Allow access to NFS')
  add_iptables_rule('INPUT', "-m tcp -p tcp -s #{other_node_ip} --dport 2049 -j ACCEPT", 200, 'Allow access to NFS')
  add_iptables_rule('INPUT', "-m udp -p udp -s #{other_node_ip} --dport 2049 -j ACCEPT", 200, 'Allow access to NFS')
  add_iptables_rule('INPUT', "-m tcp -p tcp -s #{other_node_ip} --dport #{node['nfs']['port']['statd']} -j ACCEPT", 200, 'Allow access to NFS')
  add_iptables_rule('INPUT', "-m udp -p udp -s #{other_node_ip} --dport #{node['nfs']['port']['statd']} -j ACCEPT", 200, 'Allow access to NFS')
  add_iptables_rule('INPUT', "-m tcp -p tcp -s #{other_node_ip} --dport #{node['nfs']['port']['mountd']} -j ACCEPT", 200, 'Allow access to NFS')
  add_iptables_rule('INPUT', "-m udp -p udp -s #{other_node_ip} --dport #{node['nfs']['port']['mountd']} -j ACCEPT", 200, 'Allow access to NFS')
  add_iptables_rule('INPUT', "-m tcp -p tcp -s #{other_node_ip} --dport #{node['nfs']['port']['lockd']} -j ACCEPT", 200, 'Allow access to NFS')
  add_iptables_rule('INPUT', "-m udp -p udp -s #{other_node_ip} --dport #{node['nfs']['port']['lockd']} -j ACCEPT", 200, 'Allow access to NFS')
  add_iptables_rule('INPUT', "-m tcp -p tcp -s #{other_node_ip} --dport #{node['nfs']['port']['rquotad']} -j ACCEPT", 200, 'Allow access to NFS')
  add_iptables_rule('INPUT', "-m udp -p udp -s #{other_node_ip} --dport #{node['nfs']['port']['rquotad']} -j ACCEPT", 200, 'Allow access to NFS')
end

# save to help the client recipe find me if it's also running on this same node
tag('magentostack_nfs_server')
node.save unless Chef::Config[:solo]
