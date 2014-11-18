# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: default
#
# Copyright 2014, Rackspace UK, Ltd.
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

# Stack_commons configuration attributes
# should not be changed
default['stack_commons']['stackname'] = 'magentostack'
default['magentostack']['db-autocreate']['enabled'] = false
default['magentostack']['demo']['enabled'] = false
default['magentostack']['mysql']['databases'] = {}
default['magentostack']['varnish']['backend_nodes'] = {}
default['magentostack']['varnish']['multi'] = true

# Toggle newrelic application monitoring
default['magentostack']['newrelic']['application_monitoring']['php']['enabled'] = 'false'

# Apache-fpm
default['magentostack']['web']['domain'] = 'mymagento.com'
default['magentostack']['web']['http_port'] = '80'
default['magentostack']['web']['https_port'] = '443'
default['magentostack']['web']['server_aliases'] = node['fqdn']
default['magentostack']['web']['ssl_autosigned'] = true
default['magentostack']['web']['cookbook'] = 'magentostack'
default['magentostack']['web']['template'] = 'apache2/magento_vhost.erb'
default['magentostack']['web']['fastcgi_cookbook'] = 'magentostack'
default['magentostack']['web']['fastcgi_template'] = 'apache2/fastcgi.conf'
default['magentostack']['web']['dir'] = "#{node['apache']['docroot_dir']}/magento"

site_name = node['magentostack']['web']['domain']
default['magentostack']['web']['ssl_key'] = "#{node['apache']['dir']}/ssl/#{site_name}.key"
default['magentostack']['web']['ssl_cert'] = "#{node['apache']['dir']}/ssl/#{site_name}.pem"
