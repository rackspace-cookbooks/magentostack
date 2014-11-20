#
# Cookbook Name:: wrapper
# Recipe:: default
#
# Copyright 2014, Rackspace
#

# This wrapper's default recipe is intended to build a single node magento installation.
# Add more recipes in the wrapper for other topologies/configurations of magentostack.

# redis single
%w(
  magentostack::redis_single
  redisio::install
  redisio::configure
  redisio::enable
).each do |recipe|
  include_recipe recipe
end

# redis sentinel for single
%w(
  magentostack::redis_sentinel
  redisio::sentinel
  redisio::sentinel_enable
).each do |recipe|
  include_recipe recipe
end

# normal recipes
%w(
  magentostack::mysql_base
  magentostack::apache-fpm
  magentostack::magento
).each do |recipe|
  include_recipe recipe
end
