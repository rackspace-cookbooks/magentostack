#
# Cookbook Name:: wrapper
# Recipe:: default
#
# Copyright 2014, Rackspace
#

# This wrapper's default recipe is intended to build a single node magento installation.
# Add more recipes in the wrapper for other topologies/configurations of magentostack.

%w(
  wrapper::_redis_password_single
  magentostack::redis_single
  magentostack::redis_single_slave
  magentostack::redis_sentinel
  magentostack::redis_configure
  magentostack::apache-fpm
  magentostack::magento_install
  magentostack::mysql_master
  magentostack::newrelic
  magentostack::_find_mysql
  magentostack::magento_configure
  magentostack::mysql_holland
).each do |recipe|
  include_recipe recipe
end
