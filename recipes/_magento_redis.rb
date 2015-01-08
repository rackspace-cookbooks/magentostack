# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: _magento_redis
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

session_master_name, session_master_ip, session_master_port = MagentostackUtil.best_redis_session_master(node)
if session_master_name && session_master_ip && session_master_port
  # ensure redis session store module is enabled
  xml_edit 'enable redis in ./app/etc/modules/Cm_RedisSession.xml' do
    path "#{node['magentostack']['web']['dir']}/app/etc/modules/Cm_RedisSession.xml"
    target '/config/modules/Cm_RedisSession/active[text()=\'false\']'
    fragment '<active>true</active>'
    action :replace # because this file is shipped already with CE/EE
  end

  # ensure session store is set to db in local.xml
  xml_edit 'set session_store to db in ./app/etc/local.xml' do
    path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
    target '/config/global/session_save'
    parent '/config/global'
    fragment '<session_save><![CDATA[db]]></session_save>'
    action :append_if_missing # because the whole section doesn't exist by default
  end

  redis_session_fragment = "<redis_session>
  <host>#{session_master_ip}</host>
  <port>#{session_master_port}</port>
  <password>#{MagentostackUtil.redis_session_password(node.run_state).to_s}</password>
  <timeout>2.5</timeout>
  <persistent></persistent>
  <db>2</db>
  <compression_threshold>2048</compression_threshold>
  <compression_lib>gzip</compression_lib>
  <log_level>4</log_level>
  <max_concurrency>6</max_concurrency>
  <break_after_frontend>5</break_after_frontend>
  <break_after_adminhtml>30</break_after_adminhtml>
  <bot_lifetime>7200</bot_lifetime>
  </redis_session>"

  xml_edit 'set session cache in ./app/etc/local.xml' do
    path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
    target '/config/global/redis_session'
    parent '/config/global'
    fragment redis_session_fragment
    action :append_if_missing # because the whole section doesn't exist by default
  end
else
  Chef::Log.warn('magentostack::_magento_redis could not locate a master redis session node')
end

object_master_name, object_master_ip, object_master_port = MagentostackUtil.best_redis_object_master(node)
if object_master_name && object_master_ip && object_master_port
  redis_object_fragment = "<cache>
        <backend>Cm_Cache_Backend_Redis</backend>
        <backend_options>
        <server>#{object_master_ip}</server>              <!-- or absolute path to unix socket -->
        <port>#{object_master_port}</port>
        <persistent></persistent>               <!-- Specify a unique string like \"cache-db0\" to enable persistent connections. -->
        <database>0</database>
        <password>#{MagentostackUtil.redis_object_password(node.run_state).to_s}</password>
        <force_standalone>0</force_standalone>  <!-- 0 for phpredis, 1 for standalone PHP -->
        <connect_retries>1</connect_retries>    <!-- Reduces errors due to random connection failures -->
        <read_timeout>10</read_timeout>         <!-- Set read timeout duration -->
        <automatic_cleaning_factor>0</automatic_cleaning_factor> <!-- Disabled by default -->
        <compress_data>1</compress_data>        <!-- 0-9 for compression level, recommended: 0 or 1 -->
        <compress_tags>1</compress_tags>        <!-- 0-9 for compression level, recommended: 0 or 1 -->
        <compress_threshold>20480</compress_threshold>  <!-- Strings below this size will not be compressed -->
        <compression_lib>gzip</compression_lib> <!-- Supports gzip, lzf and snappy -->
        </backend_options>
      </cache>"

  xml_edit 'set object cache in ./app/etc/local.xml' do
    path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
    target '/config/global/cache'
    parent '/config/global'
    fragment redis_object_fragment
    action :append_if_missing # because the whole section doesn't exist by default
  end
else
  Chef::Log.warn('magentostack::_magento_redis could not locate an appropriate redis object cache node')
end

# discovery function is edition (community/enterprise) aware, won't find an instance when not using enterprise
page_master_name, page_master_ip, page_master_port = MagentostackUtil.best_redis_page_master(node)
if page_master_name && page_master_ip && page_master_port
  redis_page_fragment = "<full_page_cache>
  <backend>Cm_Cache_Backend_Redis</backend>
  <backend_options>
    <server>#{page_master_ip}</server> <!-- or absolute path to unix socket for better performance -->
    <port>#{page_master_port}</port>
    <database>1</database>
    <password>#{MagentostackUtil.redis_page_password(node.run_state).to_s}</password>
    <force_standalone>0</force_standalone>  <!-- 0 for phpredis, 1 for standalone PHP -->
    <connect_retries>1</connect_retries>    <!-- Reduces errors due to random connection failures -->
    <automatic_cleaning_factor>0</automatic_cleaning_factor> <!-- Disabled by default -->
    <!-- in FPC data is already gzipped, no need to do this twice -->
    <compress_data>0</compress_data>  <!-- 0-9 for compression level, recommended: 0 or 1 -->
    <compress_tags>1</compress_tags>  <!-- 0-9 for compression level, recommended: 0 or 1 -->
    <compress_threshold>20480</compress_threshold>  <!-- Strings below this size will not be compressed -->
    <compression_lib>gzip</compression_lib> <!-- Supports gzip, lzf and snappy -->
    <lifetimelimit>43200</lifetimelimit> <!-- set lifetime for keys without TTL -->
    <persistent>2</persistent>
  </backend_options>
  </full_page_cache>"

  xml_edit 'set page cache in ./app/etc/local.xml' do
    path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
    target '/config/global/full_page_cache'
    parent '/config/global'
    fragment redis_page_fragment
    action :append_if_missing # because the whole section doesn't exist by default
  end
else
  Chef::Log.warn('magentostack::_magento_redis could not locate an appropriate redis page cache node')
end
