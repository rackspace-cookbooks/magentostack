define :magento_initial_configuration do
  # Configure all the things
  database_name = node['magentostack']['mysql']['databases'].keys[0]
  bash 'Configure Magento' do
    cwd node['magentostack']['web']['dir']
    user node['apache']['user']
    group node['apache']['group']
    code  <<-EOH
    php -f install.php -- \
    --license_agreement_accepted "yes" \
    --locale "#{node['magentostack']['config']['locale']}" \
    --timezone "#{node['magentostack']['config']['tz']}" \
    --default_currency "#{node['magentostack']['config']['default_currency']}" \
    --db_host "#{node['magentostack']['config']['db']['host']}:#{node['magentostack']['config']['db']['port']}" \
    --db_model "#{node['magentostack']['config']['db']['model']}" \
    --db_name "#{database_name}" \
    --db_user "#{node['magentostack']['mysql']['databases'][database_name]['mysql_user']}" \
    --db_pass "#{node['magentostack']['mysql']['databases'][database_name]['mysql_password']}" \
    --db_prefix "#{node['magentostack']['config']['db']['prefix']}" \
    --session_save "#{node['magentostack']['config']['session']['save']}" \
    --url "#{node['magentostack']['config']['url']}" \
    --use_rewrites "#{node['magentostack']['config']['use_rewrites']}" \
    --use_secure "#{node['magentostack']['config']['use_secure']}" \
    --secure_base_url "#{node['magentostack']['config']['secure_base_url']}" \
    --use_secure_admin "#{node['magentostack']['config']['use_secure_admin']}" \
    --enable-charts "#{node['magentostack']['config']['enable_charts']}" \
    --admin_frontname "#{node['magentostack']['config']['admin_frontname']}" \
    --admin_firstname "#{node['magentostack']['config']['admin_user']['firstname']}" \
    --admin_lastname "#{node['magentostack']['config']['admin_user']['lastname']}" \
    --admin_email "#{node['magentostack']['config']['admin_user']['email']}" \
    --admin_username "#{node['magentostack']['config']['admin_user']['username']}" \
    --admin_password "#{node['magentostack']['config']['admin_user']['password']}" \
    --encryption_key "#{node['magentostack']['config']['encryption_key']}" \
    --skip_url_validation
    touch .configured
    EOH
    not_if { File.exist?("#{node['magentostack']['web']['dir']}/app/etc/local.xml") }
  end
end
