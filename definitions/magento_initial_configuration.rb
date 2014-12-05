define :magento_initial_configuration do
  # Configure all the things
  database_name = node['magentostack']['mysql']['databases'].keys[0]

  pp node['magentostack']['web']['dir']

  # docroot_dir should be one closer to root from magento/ vhost dir
  template "#{Chef::Config[:file_cache_path]}/magentostack.sh" do
    source 'magentostack.sh.erb'
    user node['apache']['user']
    group node['apache']['group']
    mode '0700'
    variables(database_name: database_name)
  end

  bash 'Configure Magento' do
    cwd node['magentostack']['web']['dir']
    user node['apache']['user']
    group node['apache']['group']
    command "#{Chef::Config[:file_cache_path]}/magentostack.sh"
    not_if { File.exist?("#{node['magentostack']['web']['dir']}/.configured") }
  end
end
