#
# Cookbook Name:: wrapper
# Recipe:: default
#
# Copyright 2014, Rackspace
#

# This wrapper's default recipe is intended to build a single node magento installation.
# Add more recipes in the wrapper for other topologies/configurations of magentostack.

%w(
  magentostack::redis_single
  magentostack::redis_single_slave
  magentostack::redis_sentinel
  magentostack::redis_configure
  magentostack::mysql_master
  magentostack::mysql_holland
  magentostack::apache-fpm
  magentostack::magento
  magentostack::newrelic
).each do |recipe|
  include_recipe recipe
end
