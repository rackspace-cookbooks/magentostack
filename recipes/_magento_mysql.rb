# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: _magento_mysql
#
# Copyright 2014, Rackspace Hosting
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# we're going to do some dirty work here with XML files to configure redis
include_recipe 'xmledit'

xml_edit 'enable persistent connections to mysql' do
  path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
  target '/config/global/resources/default_setup/connection/persistent'
  parent '/config/global/resources/default_setup/connection'
  fragment '<persistent>1</persistent>'
  action :append_if_missing
end
