#
# Cookbook Name:: wrapper
# Recipe:: default
#
# Copyright 2014, Rackspace
#

# This wrapper's default recipe is intended to build a single node magento installation.
# Add more recipes in the wrapper for other topologies/configurations of magentostack.

%w(
  magentostack::magento
  magentostack::mysql_base
  magentostack::redis_single
  magentostack::application_php
  magentostack::apache
).each do |recipe|
  include_recipe recipe
end
