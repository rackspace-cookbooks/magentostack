# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: varnish
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
include_recipe 'yum-epel' if rhel?
include_recipe 'magentostack::modman'

varnish_install 'varnish' do
  vendor_repo true # needed for varnish >= 3
  vendor_version '3.0' # includes point releases
  action :install
end

file '/etc/varnish/secret' do
  content node['magentostack']['varnish']['secret'].to_s # in case it's false
  mode 0600
  only_if { node['magentostack']['varnish']['secret'] }
end

varnish_default_config 'varnish-config-magento' do
  listen_port node['magentostack']['varnish']['listen_port']
  parameters(
    # default for varnish
    'thread_pools' => '4',
    'thread_pool_min' => '5',
    'thread_pool_max' => '500',
    'thread_pool_timeout' => '300',

    # recommended by turpentine

    # varnish v3
    'esi_syntax' => '0x2',

    # varnish v4 when we get there
    # 'feature' => '+esi_disable_xml_check',
    'cli_buffer' => '16384'
  )
  action :configure
end

# Apache on :80, but LBs point at Varnish on :8080
varnish_default_vcl 'varnish-vcl' do
  backend_port node['magentostack']['web']['http_port'].to_i
  action :configure
end

varnish_log 'varnish-log' do
  action :configure
end

modman 'https://github.com/nexcess/magento-turpentine.git' do
  action :clone
  path node['apache']['docroot_dir']
  not_if { ::File.exist?("#{node['apache']['docroot_dir']}/.modman/magento-turpentine") }
end

add_iptables_rule('INPUT', "-m tcp -p tcp --dport #{node['magentostack']['varnish']['listen_port']} -j ACCEPT", 100, 'Allow access to varnish')
