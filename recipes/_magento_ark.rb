ark 'magento' do
  url node['magentostack']['download_url']
  path node['apache']['docroot_dir']
  owner node['apache']['user']
  group node['apache']['group']
  checksum node['magentostack']['checksum']
  action :put
end
