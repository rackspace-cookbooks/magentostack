# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Recipe:: _magento_localxml_template
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

# Configure using a supplied local.xml copy from the ark or git install methods
include_recipe 'xmledit'

ruby_block 'fail at runtime instant if missing local.xml.template' do
  block do
    raise 'local.xml.template did not exist' \
      unless File.exist?("#{node['magentostack']['web']['dir']}/app/etc/local.xml.template")
  end
end

localxml_path = "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
remote_file 'copy local.xml.template to local.xml' do
  path localxml_path
  source "file://#{node['magentostack']['web']['dir']}/app/etc/local.xml.template"
  owner node['apache']['user']
  group node['apache']['group']
  mode 0777
  action :create_if_missing
end

xml_edit 'add admin front name to local.xml' do
  path localxml_path
  target '/config/admin/routers/adminhtml/args/frontName'
  parent '/config/admin/routers/adminhtml/args'
  fragment "<frontName>#{MagentostackUtil.xml_escape_cdata(node['magentostack']['config']['admin_frontname'])}</frontName>"
  action :replace
  only_if { node['magentostack']['config']['admin_frontname'] }
end

xml_edit 'add install date to local.xml' do
  path localxml_path
  target '/config/global/install/date'
  parent '/config/global/install'
  fragment "<date>#{MagentostackUtil.xml_escape_cdata(Time.now.asctime)}</date>"
  action :append_if_missing
  only_if "grep -q '{{date}}' #{localxml_path}"
end

xml_edit 'add crypt key to local.xml' do
  path localxml_path
  target '/config/global/crypt/key'
  parent '/config/global/crypt'
  fragment "<key>#{MagentostackUtil.xml_escape_cdata(MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'config', 'encryption_key'))}</key>"
  action :replace
  only_if { node['magentostack']['config']['encryption_key'] }
end

xml_edit 'add db prefix to local.xml' do
  path localxml_path
  target '/config/global/resources/db/table_prefix'
  parent '/config/global/resources/db'
  fragment "<table_prefix>#{MagentostackUtil.xml_escape_cdata(node['magentostack']['config']['db']['prefix'])}</table_prefix>"
  action :replace
  only_if { node['magentostack']['config']['db']['prefix'] }
end

## Database-specific configuration
database_settings = %w(
  host
  username
  password
  dbname
  initStatements
  model
  type
  pdoType
  active
  persistent
)

# figure out if we're splitting reads and writes
database_split_read_write = false
database_settings.each do |connection_item|
  connection_item_write_value = MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'config', 'db_write', connection_item)
  connection_item_read_value = MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'config', 'db_read', connection_item)

  # if we find that any values have been given a write-/read-specific value, we set a flag
  next unless connection_item_read_value || connection_item_write_value
  database_split_read_write = true
end

# if database_split_read_write, remove the default database settings
xml_edit 'add default_setup to local.xml' do
  path localxml_path
  target '/config/global/resources/default_setup'
  action :remove
  only_if { database_split_read_write }
end

# if database_split_read_write, add resources/core_read
xml_edit 'add core_read to local.xml under config/global/resources' do
  path localxml_path
  target '/config/global/resources/core_read'
  parent '/config/global/resources'
  fragment '<core_read></core_read>'
  action :append_if_missing # if target is found, replace with fragment, otherwise append fragment
  only_if { database_split_read_write }
end

# if database_split_read_write, resources/add core_read/connection
xml_edit 'add connection to local.xml under config/global/resources/core_read' do
  path localxml_path
  target '/config/global/resources/core_read/connection'
  parent '/config/global/resources/core_read'
  fragment '<connection></connection>'
  action :append_if_missing # if target is found, replace with fragment, otherwise append fragment
  only_if { database_split_read_write }
end

# if database_split_read_write, add resources/add core_read/connection/use
xml_edit 'add use to local.xml under config/global/resources/core_read/connection' do
  path localxml_path
  target '/config/global/resources/core_read/connection/use'
  parent '/config/global/resources/core_read/connection'
  fragment '<use/>'
  action :append_if_missing # if target is found, replace with fragment, otherwise append fragment
  only_if { database_split_read_write }
end

# if database_split_read_write, add resources/core_write
xml_edit 'add core_write to local.xml under config/global/resources' do
  path localxml_path
  target '/config/global/resources/core_write'
  parent '/config/global/resources'
  fragment '<core_write></core_write>'
  action :append_if_missing # if target is found, replace with fragment, otherwise append fragment
  only_if { database_split_read_write }
end

# if database_split_read_write, add resources/core_write/connection
xml_edit 'add connection to local.xml under config/global/resources/core_write' do
  path localxml_path
  target '/config/global/resources/core_write/connection'
  parent '/config/global/resources/core_write'
  fragment '<connection></connection>'
  action :append_if_missing # if target is found, replace with fragment, otherwise append fragment
  only_if { database_split_read_write }
end

# if database_split_read_write, add resources/core_write/connection/use
xml_edit 'add use to local.xml under config/global/resources/core_write/connection' do
  path localxml_path
  target '/config/global/resources/core_write/connection/use'
  parent '/config/global/resources/core_write/connection'
  fragment '<use/>'
  action :append_if_missing # if target is found, replace with fragment, otherwise append fragment
  only_if { database_split_read_write }
end

# if database is NOT database_split_read_write, remove the split settings
%w(core_read core_write).each do |split_key|
  xml_edit "remove #{split_key} to local.xml" do
    path localxml_path
    target "/config/global/resources/#{split_key}"
    action :remove
    not_if { database_split_read_write }
  end
end

database_settings.each do |connection_item|
  connection_item_value = MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'config', 'db', connection_item)

  if database_split_read_write
    connection_item_read_value = MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'config', 'db_read', connection_item)
    connection_item_write_value = MagentostackUtil.get_runstate_or_attr(node, 'magentostack', 'config', 'db_write', connection_item)

    # write > read > default
    split_db_read_value = connection_item_read_value || connection_item_value
    split_db_write_value = connection_item_write_value || connection_item_value

    # read value (will be inherited from connection_item_value if one isn't given)
    xml_edit "add #{connection_item} to local.xml under core_read" do
      path localxml_path
      target "/config/global/resources/core_read/connection/#{connection_item}"
      parent '/config/global/resources/core_read/connection'
      fragment "<#{connection_item}>#{MagentostackUtil.xml_escape_cdata(split_db_read_value)}</#{connection_item}>"
      action :append_if_missing # if target is found, replace with fragment, otherwise append fragment
      only_if { split_db_read_value }
    end

    # write value
    xml_edit "add #{connection_item} to local.xml under core_write" do
      path localxml_path
      target "/config/global/resources/core_write/connection/#{connection_item}"
      parent '/config/global/resources/core_write/connection'
      fragment "<#{connection_item}>#{MagentostackUtil.xml_escape_cdata(split_db_write_value)}</#{connection_item}>"
      action :append_if_missing # if target is found, replace with fragment, otherwise append fragment
      only_if { split_db_write_value }
    end
  else
    xml_edit "add #{connection_item} to local.xml" do
      path localxml_path
      target "/config/global/resources/default_setup/connection/#{connection_item}"
      parent '/config/global/resources/default_setup/connection'
      fragment "<#{connection_item}>#{MagentostackUtil.xml_escape_cdata(connection_item_value)}</#{connection_item}>"
      action :append_if_missing # if target is found, replace with fragment, otherwise append fragment
      only_if { connection_item_value }
    end
  end
end

## Redis configuration

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
    path localxml_path
    target '/config/global/session_save'
    parent '/config/global'
    fragment '<session_save><![CDATA[db]]></session_save>'
    action :append_if_missing # because the whole section doesn't exist by default
  end

  redis_session_fragment = "<redis_session>
  <host>#{session_master_ip}</host>
  <port>#{session_master_port}</port>
  <password>#{MagentostackUtil.redis_session_password(node)}</password>
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
    path localxml_path
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
        <password>#{MagentostackUtil.redis_object_password(node)}</password>
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
    path localxml_path
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
    <password>#{MagentostackUtil.redis_page_password(node)}</password>
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
    path localxml_path
    target '/config/global/full_page_cache'
    parent '/config/global'
    fragment redis_page_fragment
    action :append_if_missing # because the whole section doesn't exist by default
  end
else
  Chef::Log.warn('magentostack::_magento_redis could not locate an appropriate redis page cache node')
end
