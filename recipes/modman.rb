# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: modman
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

# TODO: Figure out how to do this by automation:
#
# If you want to use modman you need to configure Magento to allow
# rendering templates that are being symlinked. Please go to
# System > Configuration > Advanced > Developer and enable Allow Symlinks.

include_recipe 'modman' unless ::File.exist?("#{node['modman']['install_path']}/modman")
modman_path = node['apache']['docroot_dir']
modman_basedir = node['magentostack']['web']['dir'].gsub("#{modman_path}/", '')
modman 'initialize modman one time' do
  basedir modman_basedir
  path modman_path
  action :init
  not_if { ::File.exist?("#{node['apache']['docroot_dir']}/.modman") }
end

node['magentostack']['modman'].each_pair do |module_name, module_url|
  modman module_url do
    action :clone
    path modman_path
    not_if { ::File.exist?("#{node['apache']['docroot_dir']}/.modman/#{module_name}") }
  end
end
