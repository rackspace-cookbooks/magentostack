#
# Cookbook Name:: wrapper
# Recipe:: default
#
# Copyright 2014, Rackspace
#
#
%w(
  magentostack::apache-fpm
).each do |recipe|
  include_recipe recipe
end
