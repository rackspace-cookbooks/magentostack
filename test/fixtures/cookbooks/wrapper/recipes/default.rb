#
# Cookbook Name:: wrapper
# Recipe:: default
#
# Copyright 2014, Rackspace
#
#
%w(
  phpstack::mysql_base
  phpstack::mongodb_standalone
  phpstack::memcache
  phpstack::varnish
  phpstack::redis_single
  phpstack::application_php
).each do |recipe|
  include_recipe recipe
end
