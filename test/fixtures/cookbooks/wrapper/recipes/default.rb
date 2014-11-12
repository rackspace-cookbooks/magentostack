#
# Cookbook Name:: wrapper
# Recipe:: default
#
# Copyright 2014, Rackspace
#

# This wrapper's default recipe is intended to build a single node magento installation.

%w(
  magentostack::mysql_base
  magentostack::redis_single
  magentostack::application_php
).each do |recipe|
  include_recipe recipe
end
