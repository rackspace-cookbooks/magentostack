# Configure using a supplied local.xml copy from the ark or git install methods

# db_name: node.run_state['magentostack_installer_database_name'],
# db_host: node.run_state['magentostack_installer_database_host'],
# db_user: node.run_state['magentostack_installer_database_user'],
# db_pass: node.run_state['magentostack_installer_database_pass'],
# magento_configured_file: node.run_state['magentostack_installer_magento_configured_file']
ruby_block 'fail if missing local.xml.template' do
  block do
    fail 'local.xml.template did not exist' \
      unless File.exist?("#{node['magentostack']['web']['dir']}/app/etc/local.xml.template")
  end
end

remote_file 'copy local.xml.template to local.xml' do
  path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
  source "file://#{node['magentostack']['web']['dir']}/app/etc/local.xml.template"
  owner node['apache']['user']
  group node['apache']['group']
  mode 0777
  action :create_if_missing
end

xml_edit 'add install date to local.xml' do
  path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
  target '/config/global/install/date'
  parent '/config/global/install'
  fragment "<date><![CDATA[#{Time.now.asctime}]]></date>"
  action :append_if_missing
  only_if "grep -q '{{date}}' #{node['magentostack']['web']['dir']}/app/etc/local.xml"
end

xml_edit 'add crypt key to local.xml' do
  path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
  target '/config/global/crypt/key'
  parent '/config/global/crypt'
  fragment "<key><![CDATA[#{node['magentostack']['config']['encryption_key']}]]></key>"
  action :append_if_missing
  only_if { node['magentostack']['config']['encryption_key'] }
end

xml_edit 'add db prefix to local.xml' do
  path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
  target '/config/global/resources/db/table_prefix'
  parent '/config/global/resources/db'
  fragment "<table_prefix><![CDATA[#{node['magentostack']['config']['db']['prefix']}]]></table_prefix>"
  action :append_if_missing
  only_if { node['magentostack']['config']['db']['prefix'] }
end

database_host = node.run_state['magentostack_installer_database_host']
xml_edit 'add database host to local.xml' do
  path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
  target '/config/global/resources/default_setup/connection/host'
  parent '/config/global/resources/default_setup/connection'
  fragment "<host><![CDATA[#{database_host}]]></host>"
  action :append_if_missing
  only_if { database_host }
end

database_user = node.run_state['magentostack_installer_database_user']
xml_edit 'add database username to local.xml' do
  path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
  target '/config/global/resources/default_setup/connection/username'
  parent '/config/global/resources/default_setup/connection'
  fragment "<username><![CDATA[#{database_user}]]></username>"
  action :append_if_missing
  only_if { database_user }
end

database_pass = node.run_state['magentostack_installer_database_pass']
xml_edit 'add database password to local.xml' do
  path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
  target '/config/global/resources/default_setup/connection/password'
  parent '/config/global/resources/default_setup/connection'
  fragment "<password><![CDATA[#{database_pass}]]></password>"
  action :append_if_missing
  only_if { database_pass }
end

database_name = node.run_state['magentostack_installer_database_name']
xml_edit 'add database name to local.xml' do
  path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
  target '/config/global/resources/default_setup/connection/dbname'
  parent '/config/global/resources/default_setup/connection'
  fragment "<dbname><![CDATA[#{database_name}]]></dbname>"
  action :append_if_missing
  only_if { database_name }
end

xml_edit 'add admin front name to local.xml' do
  path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
  target '/config/admin/routers/adminhtml/args/frontName'
  parent '/config/admin/routers/adminhtml/args'
  fragment "<frontName><![CDATA[#{node['magentostack']['config']['admin_frontname']}]]></frontName>"
  action :append_if_missing
  only_if { node['magentostack']['config']['admin_frontname'] }
end

xml_edit 'add db model to local.xml' do
  path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
  target '/config/global/resources/default_setup/connection/model'
  parent '/config/global/resources/default_setup/connection'
  fragment "<model><![CDATA[#{node['magentostack']['config']['db']['model']}]]></model>"
  action :append_if_missing
  only_if { node['magentostack']['config']['db']['model']
end

%w(
  initStatements
  type
  pdoType
).each do |connection_item|
  xml_edit "add #{connection_item} to local.xml" do
    path "#{node['magentostack']['web']['dir']}/app/etc/local.xml"
    target "/config/global/resources/default_setup/connection/#{connection_item}"
    parent '/config/global/resources/default_setup/connection'
    fragment "<#{connection_item}><![CDATA[#{node['magentostack']['localxml']['connection'][connection_item]}]]></#{connection_item}>"
    action :append_if_missing
    only_if { node['magentostack']['localxml']['connection'][connection_item] }
  end
end
