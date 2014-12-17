# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: _magento_cloudfiles
#
# Copyright 2014, Rackspace Hosting
#

# required for stack_commons::mysql_base to find the app nodes
tag('magento_app_node')
node.save unless Chef::Config[:solo]

%w(
  magentostack::redis_object
  magentostack::redis_object_slave
  magentostack::redis_page
  magentostack::redis_page_slave
  magentostack::redis_session
  magentostack::redis_session_slave
  magentostack::redis_sentinel
  magentostack::redis_configure
  magentostack::mysql_master
  magentostack::mysql_holland
  magentostack::apache-fpm
  magentostack::newrelic
  magentostack::magento
).each do |recipe|
  include_recipe recipe
end
