#
# Cookbook Name:: wrapper
# Recipe:: default
#
# Copyright 2014, Rackspace
#

# This wrapper's default recipe is intended to build a single node magento installation.
# Add more recipes in the wrapper for other topologies/configurations of magentostack.

def enterprise?
  node['magentostack'] && node['magentostack']['flavor'] == 'enterprise'
end

# we still install redis for sessions and objects, even in CE
%w(
  wrapper::_redis_password_single
  magentostack::redis_single
  magentostack::redis_single_slave
  magentostack::redis_sentinel
  magentostack::redis_configure
  magentostack::apache-fpm
  magentostack::magento_install
  magentostack::nfs_server
  magentostack::nfs_client
  magentostack::mysql_master
  magentostack::newrelic
  magentostack::_find_mysql
  magentostack::magento_configure
  magentostack::magento_admin
  magentostack::mysql_holland
  magentostack::users
).each do |recipe|
  include_recipe recipe
end

# if enterprise edition, also enable the FPC for testing
if enterprise?
  include_recipe 'magentostack::_magento_fpc'
else
  include_recipe 'magentostack::varnish'
  include_recipe 'magentostack::_magento_turpentine'
end
