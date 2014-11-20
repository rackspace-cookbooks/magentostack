#
# Cookbook Name:: wrapper
# Recipe:: default_expanded
#
# Copyright 2014, Rackspace
#

# This wrapper's default recipe is intended to build a single node magento
# installation with all components split apart (such as separate redis instances)
#
# Add more recipes in the wrapper for other topologies/configurations of magentostack.

%w(
  magentostack::redis_object
  magentostack::redis_page
  magentostack::redis_session
  redisio::install
  redisio::configure
  redisio::enable
  magentostack::redis_sentinel
  redisio::sentinel
  redisio::sentinel_enable
  magentostack::mysql_base
  magentostack::apache-fpm
  magentostack::magento
).each do |recipe|
  include_recipe recipe
end
