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

package 'git'

git '/root/cm_redis_tools' do
  repository 'https://github.com/samm-git/cm_redis_tools'
  revision node['magentostack']['redis']['tag_cleanup']['revision']
  action :checkout
end

_redis_name, redis_ip, redis_port = MagentostackUtil.best_redis_object_master(node)
databases = node['magentostack']['redis']['tag_cleanup']['databases']

cron 'redis_tag_cleanup' do
  command "/usr/bin/php /root/cm_redis_tools/rediscli.php -s #{redis_ip} -p #{redis_port} -d #{databases}"
  minute node['magentostack']['redis']['tag_cleanup']['minute']
  hour node['magentostack']['redis']['tag_cleanup']['hour']
  day node['magentostack']['redis']['tag_cleanup']['day']
  weekday node['magentostack']['redis']['tag_cleanup']['weekday']
  month node['magentostack']['redis']['tag_cleanup']['month']
  action :create
end
