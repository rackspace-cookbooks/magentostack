include_recipe 'chef-sugar'

# ensure they asked for a valid install method
install_method = node['magentostack']['install_method']

case install_method
when 'cloudfiles'
  # these can be populated in a wrapper using a data bag and then placed in node.run_state
  # or simply populated via environment, role, or node attributes
  rackspace_username = node.run_state['rackspace_cloud_credentials_username'] || node.deep_fetch('rackspace', 'cloud_credentials', 'username')
  rackspace_api_key = node.run_state['rackspace_cloud_credentials_api_key'] || node.deep_fetch('rackspace', 'cloud_credentials', 'api_key')
  download_file = node['magentostack']['download_file']

  # install these for nokogiri for xml for fog gem for rackspacecloud
  include_recipe 'build-essential'
  include_recipe 'rackspacecloud'

  # this will fail to be created as a resource, even when not being used, if
  # rackspace_username or rackspace_api_key are nil, so we guard it in a big if.
  rackspacecloud_file "#{Chef::Config[:file_cache_path]}/#{download_file}" do
    directory node['magentostack']['download_dir']
    rackspace_username rackspace_username
    rackspace_api_key rackspace_api_key
    rackspace_region node['magentostack']['download_region']
    binmode true
    action :create
  end

  ark 'magento' do
    url "file://#{Chef::Config[:file_cache_path]}/#{download_file}"
    path node['apache']['docroot_dir']
    owner node['apache']['user']
    group node['apache']['group']
    checksum node['magentostack']['checksum']
    action :put
  end
when 'ark'
  ark 'magento' do
    url node['magentostack']['download_url']
    path node['apache']['docroot_dir']
    owner node['apache']['user']
    group node['apache']['group']
    checksum node['magentostack']['checksum']
    action :put
  end
when 'none'
  Chef::Log.info('Magento install method none was requested, not installing magento')
else
  fail "You have specified to install magento with method #{install_method}, which is not valid."
end

# required for stack_commons::mysql_base to find the app nodes
tag('magento_app_node')
node.save unless Chef::Config[:solo] # make me searchable right away!
