# Encoding: utf-8
#
# Cookbook Name:: magentostack
# Attributes:: magento
#
# Copyright 2014, Rackspace UK, Ltd.
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

# Where to get Magento, can be http link or git path
default['magentostack']['install_method'] = 'ark' # can be ark, git, svn, cloudfiles, or none

# How to configure magento initially
default['magentostack']['configure_method'] = 'installer' # can be installer, template, or none

# Distribution of magento and a checksum for that download
default['magentostack']['checksum'] = 'e04c75f1be09844b92f5bbae04e417961447908000c591a29471b8634440dd1b'
default['magentostack']['flavor'] = 'community' # could also be enterprise

# for ark download method
default['magentostack']['download_url'] = 'http://www.magentocommerce.com/downloads/assets/1.9.1.1/magento-1.9.1.1.tar.gz'

# for cloudfiles download method
default['magentostack']['download_region'] = 'iad'
default['magentostack']['download_dir'] = 'magento'
default['magentostack']['download_file'] = 'magento.tar.gz'

# for git download method
default['magentostack']['git_repository'] = 'git@github.com:example/deployment.git'
default['magentostack']['git_revision'] = 'master' # e.g. staging, testing, dev
default['magentostack']['git_deploykey'] = nil
default['magentostack']['git_submodules'] = false

# Database creation by the mysql cookbook
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
### We *do* look in node.run_state first
default['magentostack']['config']['db']['prefix'] = ''
default['magentostack']['config']['db']['initStatements'] = 'SET NAMES utf8'
default['magentostack']['config']['db']['model'] = 'mysql4'
default['magentostack']['config']['db']['type'] = 'pdo_mysql'
default['magentostack']['config']['db']['pdoType'] = ''
default['magentostack']['config']['db']['active'] = 1
default['magentostack']['config']['db']['persistent'] = 1

## Admin user
default['magentostack']['config']['admin_frontname'] = 'admin'
default['magentostack']['config']['admin_user']['firstname'] = 'Admin'
default['magentostack']['config']['admin_user']['lastname'] = 'User'
default['magentostack']['config']['admin_user']['email'] = 'admin@example.org'
default['magentostack']['config']['admin_user']['username'] = 'MagentoAdmin'
default['magentostack']['config']['admin_user']['password'] = 'magPass.123'

## Other configs
default['magentostack']['config']['encryption_key'] = nil
default['magentostack']['config']['session']['save'] = 'db'

default['magentostack']['config']['use_rewrites'] = 'yes'
default['magentostack']['config']['use_secure'] = 'yes'
default['magentostack']['config']['use_secure_admin'] = 'yes'
default['magentostack']['config']['enable_charts'] = 'yes'
