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

include_recipe 'chef-sugar'
# we still install redis for sessions and objects, even in CE
recipes_to_run = []

recipes_to_run << %w(
  wrapper::_redis_password_single
  magentostack::redis_single
  magentostack::redis_single_slave
  magentostack::redis_sentinel
  magentostack::redis_configure
)

if node.deep_fetch('magentostack_wrapper', 'webserver') == 'nginx'
  recipes_to_run << 'magentostack::nginx-fpm'
else
  recipes_to_run << 'magentostack::apache-fpm'
end

recipes_to_run << %w(
  magentostack::magento_install
  magentostack::nfs_server
  magentostack::nfs_client
  magentostack::mysql_master
  magentostack::newrelic
  magentostack::_find_mysql
  magentostack::magento_configure
  magentostack::magento_admin
  magentostack::mysql_holland
)

# if enterprise edition, also enable the FPC for testing
if enterprise?
  recipes_to_run << 'magentostack::_magento_fpc'
else
  recipes_to_run << %w(
    magentostack::varnish
    magentostack::_magento_turpentine
  )
end

recipes_to_run.flatten.each do |recipe|
  include_recipe recipe
end
