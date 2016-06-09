# Encoding: utf-8
name 'magentostack'
maintainer 'Rackspace'
maintainer_email 'rackspace-cookbooks@rackspace.com'
license 'Apache 2.0'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
description 'Provides a full Magento stack'
version '2.2.2'

depends 'stack_commons', '>= 0.0.50'
depends 'platformstack', '>= 3.1.4'
depends 'rackspacecloud'
depends 'rackspace_iptables'
depends 'varnish'
depends 'modman'

depends 'apache2'
depends 'apt'
depends 'ark'
depends 'build-essential'
depends 'certificate'
depends 'chef-sugar'
depends 'cron'
depends 'database'
depends 'git'
depends 'logrotate'
depends 'mysql-multi'
depends 'nfs', '>= 2.2.6'
depends 'openssl'
depends 'parted'
depends 'partial_search'
depends 'php-fpm'
depends 'redisio'
depends 'subversion'
depends 'yum'
depends 'yum-ius'
depends 'yum-epel'
depends 'xml'
depends 'xmledit'
depends 'sudo'
depends 'chef-sugar-rackspace'
depends 'users'
