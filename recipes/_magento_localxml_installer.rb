# Run install.php script for initial magento setup
# We must be sure we know all important configuration to pass to magento at this point

# temporary location for script that runs install.php
setup_script = "#{Chef::Config[:file_cache_path]}/magentostack.sh"

template setup_script do
  source 'magentostack.sh.erb'
  user node['apache']['user']
  group node['apache']['group']
  mode '0700'
  variables(
    db_name: node.run_state['magentostack_installer_database_name'],
    db_host: node.run_state['magentostack_installer_database_host'],
    db_user: node.run_state['magentostack_installer_database_user'],
    db_pass: node.run_state['magentostack_installer_database_pass'],
    magento_configured_file: node.run_state['magentostack_installer_magento_configured_file']
  )
end

cookbook_file "#{node['magentostack']['web']['dir']}/check-magento-installed.php" do
  source 'check-magento-installed.php'
  user node['apache']['user']
  group node['apache']['group']
  mode '0700'
end

unless includes_recipe?('magentostack::magento_admin')
  execute 'wait_for_admin_to_start_config' do
    command 'sleep 60'
    not_if { File.exist?(node.run_state['magentostack_installer_magento_configured_file']) }
  end
end

execute setup_script do
  cwd node['magentostack']['web']['dir']
  user node['apache']['user']
  group node['apache']['group']
  not_if { File.exist?(node.run_state['magentostack_installer_magento_configured_file']) }
end
