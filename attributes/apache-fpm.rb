# there is a bug in mod_fastcgi, Magento <1.9 or EE <1.14 need this mod_fastcgi
# only require if we decide to use Magento <1.9 or EE <1.14
# default['apache']['mod_fastcgi']['download_url'] = 'http://www.fastcgi.com/dist/mod_fastcgi-SNAP-0910052141.tar.gz'

# Configure default Magento Vhosts
default['magentostack']['web']['domain'] = 'localhost'
default['magentostack']['web']['http_port'] = '80'
default['magentostack']['web']['https_port'] = '443'
default['magentostack']['web']['server_aliases'] = node['fqdn']
default['magentostack']['web']['ssl_autosigned'] = true
default['magentostack']['web']['cookbook'] = 'magentostack'
default['magentostack']['web']['template'] = 'apache2/magento_vhost.erb'
default['magentostack']['web']['fastcgi_cookbook'] = 'magentostack'
default['magentostack']['web']['fastcgi_template'] = 'apache2/fastcgi.conf'
default['magentostack']['web']['dir'] = "#{node['apache']['docroot_dir']}/magento"

site_name = node['magentostack']['web']['domain']
default['magentostack']['web']['ssl_key'] = "#{node['apache']['dir']}/ssl/#{site_name}.key"
default['magentostack']['web']['ssl_cert'] = "#{node['apache']['dir']}/ssl/#{site_name}.pem"

# Install php dependencies for Magento
case node['platform_family']
when 'rhel'
  default['magentostack']['php']['packages'] = %w(
    php55u-gd
    php55u-mysqlnd
    php55u-mcrypt
    php55u-xml
    php55u-xmlrpc
    php55u-soap
    php55u-pecl-redis
    php55u-opcache
  )
### opcache is built in Php for Ubuntu
when 'debian'
  default['magentostack']['php']['packages'] = %w(
    php5-gd
    php5-mysqlnd
    php5-mcrypt
    php5-xmlrpc
    php5-redis
    php5-curl
  )
end
#    php5-soap

# cloud monitoring
node.default['magentostack']['web']['monitor']['cookbook'] = 'magentostack'
node.default['magentostack']['web']['monitor']['template'] = 'cloud-monitoring/monitoring-remote-http.yaml.erb'
node.default['magentostack']['web']['monitor']['disabled'] = false
node.default['magentostack']['web']['monitor']['period'] = 60
node.default['magentostack']['web']['monitor']['timeout'] = 15
node.default['magentostack']['web']['monitor']['alarm'] = false
