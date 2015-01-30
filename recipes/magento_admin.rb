# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: magento_admin
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

# Ensure the cron.sh file has correct permission
file "#{node['apache']['docroot_dir']}/magento/cron.sh" do
  mode '755'
  action :touch
end

cron 'magento_cron' do
  action :create
  path '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin'
  minute '*/5'
  user node['apache']['user']
  command "#{node['apache']['docroot_dir']}/magento/cron.sh"
end
