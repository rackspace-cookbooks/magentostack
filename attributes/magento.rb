# Where to get Magento, can be http link or git path
default['magentostack']['install_method'] = 'ark' # can be ark, git, cloudfiles, or none
default['magentostack']['checksum'] = '338df88796a445cd3be2a10b5c79c50e9900a4a1b1d8e9113a79014d3186a8e0'
default['magentostack']['flavor'] = 'community' # could also be enterprise

# for ark download method
default['magentostack']['download_url'] = 'http://www.magentocommerce.com/downloads/assets/1.9.0.1/magento-1.9.0.1.tar.gz'

# for cloudfiles download method
default['magentostack']['download_region'] = 'ORD'
default['magentostack']['download_dir'] = 'magento'
default['magentostack']['download_file'] = 'magento.tar.gz'

# for git download method
default['magentostack']['git_repository'] = 'git@github.com:example/deployment.git'
default['magentostack']['git_revision'] = 'master' # e.g. staging, testing, dev
default['magentostack']['git_deploykey'] = nil

# Database creation
normal['magentostack']['mysql']['databases']['magento_database']['mysql_user'] = 'magento_user'
normal['magentostack']['mysql']['databases']['magento_database']['mysql_password'] = 'magento_password'
normal['magentostack']['mysql']['databases']['magento_database']['privileges'] = ['all']
normal['magentostack']['mysql']['databases']['magento_database']['global_privileges'] = [:usage, :select, :'lock tables', :'show view', :reload, :super]

# Magento configuration
## localisation
default['magentostack']['config']['tz'] = 'Etc/UTC'
default['magentostack']['config']['locale'] = 'en_US'
default['magentostack']['config']['default_currency'] = 'GBP'

## Database
### run_state rather than default?
default['magentostack']['config']['db']['prefix'] = 'magento_'
default['magentostack']['config']['db']['model'] = 'mysql4'

## Admin user
default['magentostack']['config']['admin_frontname'] = 'admin'
default['magentostack']['config']['admin_user']['firstname'] = 'Admin'
default['magentostack']['config']['admin_user']['lastname'] = 'User'
default['magentostack']['config']['admin_user']['email'] = 'admin@example.org'
default['magentostack']['config']['admin_user']['username'] = 'MagentoAdmin'
default['magentostack']['config']['admin_user']['password'] = 'magPass.123'

## Other configs
default['magentostack']['config']['session']['save'] = 'db'

default['magentostack']['config']['use_rewrites'] = 'yes'
default['magentostack']['config']['use_secure'] = 'yes'
default['magentostack']['config']['use_secure_admin'] = 'yes'
default['magentostack']['config']['enable_charts'] = 'yes'
