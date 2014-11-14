# Encoding: utf-8
#
# Cookbook Name:: phpstack
# Recipe:: apache
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

# repo dependencies for php-fpm
if platform_family?('rhel')
  include_recipe 'yum'
  include_recipe 'yum-epel'
  include_recipe 'yum-ius'
elsif platform_family?('debian')
  include_recipe 'apt'
end

# Modules depedencies (Magento/Php-fpm)
node.default['apache']['default_modules'] = %w(
  status actions alias auth_basic
  authn_file authz_default
  authz_groupfile authz_host
  authz_user autoindex dir env mime
  negotiation setenvif ssl headers
  expires log_config logio
)

%w(
  apache2
  apache2::mod_fastcgi
  php-fpm
).each do |recipe|
  include_recipe recipe
end


# create self signed certificate (enable by default)
if node['magentostack']['web']['ssl_autosigned']
  openssl_x509 node['magentostack']['web']['ssl_cert'] do
    common_name node.name
    org 'Magento'
    org_unit 'Magento'
    country 'US'
    key_file node['magentostack']['web']['ssl_key']
  end
end

# Fast-cgi configuration
apache_conf "fastcgi" do
  enable true
end

# Create documentroot
directory node['magentostack']['web']['dir'] do
  action :create
  not_if {File.exists?(node['magentostack']['web']['dir'])}
end

# Create vhost
%w(default ssl).each do |site|
  web_app "#{site}" do
    template node['magentostack']['web']['template']
    cookbook node['magentostack']['web']['cookbook']
    http_port node['magentostack']['web']['http_port']
    docroot node['magentostack']['web']['dir']
    server_name node['magentostack']['web']['domain']
    server_aliases node['magentostack']['web']['server_aliases']
    ssl true if site == 'ssl'
    https_port node['magentostack']['web']['https_port']
    ssl_cert node['magentostack']['web']['ssl_cert']
    ssl_key node['magentostack']['web']['ssl_key']
  end
end



# to add to include_recipe  platformstack::monitors
#template "http-monitor-#{site_opts['server_name']}-#{port}" do
#  cookbook stackname
#  source 'monitoring-remote-http.yaml.erb'
#  path "/etc/rackspace-monitoring-agent.conf.d/#{site_opts['server_name']}-#{port}-http-monitor.yaml"
#  owner 'root'
#  group 'root'
#  mode '0644'
#  variables(
#    http_port: port,
#    server_name: site_opts['server_name']
#  )
#  notifies 'restart', 'service[rackspace-monitoring-agent]', 'delayed'
#  action 'create'
#  only_if { node.deep_fetch('platformstack', 'cloud_monitoring', 'enabled') }
#end
