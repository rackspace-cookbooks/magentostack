# magentostack

## Supported Platforms

- CentOS 6.5
- Ubuntu 12.04 (untested)
- Ubuntu 14.04 (untested)

## Supported Magento version
Community Edition >= 1.9
Enterprise Edition >= 1.14.1

## Requirements

- Chef 12 or greater.

### Cookbooks

- `stack_commons`
- `platformstack`
- `rackspacecloud`
- `rackspace_iptables`
- `varnish`
- `modman`
- `apache2`
- `apt`
- `ark`
- `git`
- `svn`
- `build-essential`
- `certificate`
- `chef-sugar`
- `cron`
- `database`
- `git`
- `logrotate`
- `mysql-multi`
- `nfs`
- `openssl`
- `parted`
- `partial_search`
- `php-fpm`
- `redisio`
- `yum`
- `yum-ius`
- `yum-epel`
- `xml`
- `xmledit`

## Recipes

### apache-fpm
This recipe sets Apache2 configuration so you can deploy your Magento code.
Configures Apache with PHP FPM.
Enables magento required php modules.
Create a self-signed certificate if node['magentostack']['web']['ssl_autosigned'] (default to true).
Create a Vhost for Magento (non-SSL).
Create a Vhost for Magento (SSL).
- toggles
  - certificate generation node['magentostack']['web']['ssl_autosigned']

You may disable SSL support by setting `node.set['magentostack']['web']['ssl'] = false`. Note that you may still need to be sure Magento redirects work correctly in this case.

You may supply a custom SSL certificate by setting one or more of these values:
```
node['magentostack']['web']['ssl_custom'] = true
node['magentostack']['web']['ssl_custom_databag'] = 'certificates'
node['magentostack']['web']['ssl_custom_databag_item'] = 'magento'
```

See instructions in [the certificate cookbook](https://github.com/atomic-penguin/cookbook-certificate#requirements) for how to prepare an appropriate encrypted data bag.

> Only Community Edition >= 1.9 and Enterprise Edition >= 1.14.1 are supported by Magentostack, therefore it's PHP 5.5 only

<!---
# Only for Magento CE <1.9 or EE < 1.14 (not supported yet)
apache2::mod_fastcgi doesn't allow to compile mod_Fastcgi from source, therefore it will not use the mod_fastcgi patched version. It means Ubuntu with Magento CE <1.9 or EE < 1.14 might have some bugs. [References](http://www.magentocommerce.com/boards/m/viewthread/229253/)
--->

### varnish and modman
In order to use Varnish, include the varnish recipe in your wrapper or ensure you're set to community edition, where Varnish is enabled by default. This installs varnish using default settings, as well as modman and installs the turpentine module for Magento.

Under `System > Configuration > Web > Secure` change the Offloader header value to `HTTP_X_FORWARDED_PROTO` (from the default SSL_OFFLOADED) and make sure the Base URL has `https` for the protocol, then save.

You should also ensure you set `node['magentostack']['varnish']['secret']` to something on each server, and then also set that value in the Administration GUI in Magento, and do an initial flush of the Varnish cache.

See the [main page about turpentine](http://www.magentocommerce.com/magento-connect/turpentine-varnish-cache.html), the [installation instructions for turpentine](https://github.com/nexcess/magento-turpentine/wiki/Installation), and the [modman Github site](https://github.com/colinmollenhour/modman), for more information and documentation.

### gluster
Sets up glusterfs based on the `node['rackspace_gluster']['config']['server']['glusters']` attribute.
This may involve some manual setup, it is glusterfs afterall

### magento_admin
Set up a cronjob to run Magento admin tasks.

### magento_install
Download and extract Magento, consulting `node['magentostack']['install_method']` for 'cloudfiles', 'ark', or 'git'.

### magento_configure
Install Magento by running install.php (basic configuration, DB bootstrap, SSL url etc...).
Or by copying a provided local.xml.template and editing it in-place from there.
*Note*: It will always edit the local.xml after the fact with values from chef.

### mysql_add_drive
Formats /dev/xvde1 and will prepare it for the mysql datadir.
Creates the mysql user and manages the /var/lib/mysql mountpoint.

### mysql_holland
---
Warning
mysql_holland package will install python-setup tools preventing to apply this fix https://github.com/rackspace-cookbooks/stack_commons/pull/86, so you must include magentostack::mysql_holland as late as possible in your run_list.
---
Installs holland.
Will set up a backup job based on if you are running as a slave or not.

### mysql_master
Sets up mysql master (runs the mysql_base recipe as well).
Will allow slaves to connect (via iptables).

### mysql_slave
Sets up the mysql slave (runs the mysql_base recipe as well).
Allows the master to connect (via iptables).

### nfs_client and nfs_server
Server recipe installs nfs server and configures an export (by default, under /exports) for magento media.
Client recipe creates a mount point, and mounts the export from the server (uses search with a tag to find the server).

### newrelic
Sets up newrelic and the php agent for newrelic.

### redis recipes

Please note that the redis recipes use an accumulator pattern, just like their upstream cookbook. This means you must include all redis recipes for instances and they will build on to the data structure containing all redis instances.

Once all redis instances have been defined, call `magentostack::redis_configure` to actually install and configure all redis masters, slaves, or sentinels that were previously declared using the individual recipes below, as well as configure any iptables rules that are required (assuming platformstack has iptables turned on).

For example, this would an appropriate runlist for a single instance, a single
slave, and the appropriate sentinel:
```
  magentostack::redis_single
  magentostack::redis_single_slave
  magentostack::redis_sentinel
  magentostack::redis_configure
```

Example for installing just the session instance:
```
  magentostack::redis_session
  magentostack::redis_configure
```
or only its slave:
```
  magentostack::redis_session_slave
  magentostack::redis_configure
```

Example to get a sentinel only:
```
  magentostack::redis_sentinel
  magentostack::redis_configure
```

#### redis_single
Configures a standalone redis server in `node['redisio']['servers']`.
Redis server bound to `node['magentostack']['redis']['bind_port_single']`.
Tags node with `magentostack_redis` and `magentostack_redis_single` for discovery.

#### redis_object, redis_page, redis_session
Configures a redis server in `node['redisio']['servers']`.
Instance is bound to `node['magentostack']['redis']['bind_port_X']` where X is object, page, or session.
Tags node with `magentostack_redis` and `magentostack_redis_X` for later discovery.

#### redis_sentinel
Sets up redis sentinel bound to `node['magentostack']['redis']['bind_port_sentinel']`.
Uses discovery in `libraries/util.rb` to find all redis servers in current chef environment.
Discovery is based on tags and chef environment, see `node['magentostack']['redis']['discovery_query']` to override.
Determines a master (using tags) in this order: redis_session.rb, redis_single.rb, `none`.
Assumes a session store is the most important to monitor (upstream only supports configuring sentinel to monitor one master).

#### redis_configure
Shortcut to run all of the redisio recipes needed to install & configure redis.
Should be used after any calls to the redis_(single/object/page/session/sentinel) recipes build any iptables rules and call `add_iptables_rule` on them.


## Attributes

### default

- `default['magentostack']['newrelic']['application_monitoring'] = ''`
  - controls if we allow newrelic to to do application monitoring
    - is set to `'true'` in the newrelic recipe
- `default['magentostack']['mysql']['databases'] = {}`
  - contains a list of databases to set up (along with users / passwords)
- `default['magentostack']['apache']['sites'] = {}`
  - Default attribute required by stack_commons *not used by Magentostack*

### Apache-fpm
- `default['magentostack']['web']['domain']`
  - Vhost Servername
- `default['magentostack']['web']['http_port']`
  - port for non-SSL vhost
- `default['magentostack']['web']['https_port']`
  - port for SSL vhost
default['magentostack']['web']['server_aliases'] = node['fqdn']
- `default['magentostack']['web']['cookbook']` and `default['magentostack']['web']['template']`
  - where to find the Vhost templates
- `default['magentostack']['web']['fastcgi_cookbook']` and `default['magentostack']['web']['fastcgi_template']`
  - where to find the Fast-cgi templates
- `default['magentostack']['web']['dir']`
  - Documenent root (where to put Magento code)
- `default['magentostack']['web']['ssl_key']` and `default['magentostack']['web']['ssl_cert']` and `default['magentostack']['web']['ssl_chain']`
  - where are the certificates and keys and a chain/intermediate(might be useful when disabling self-signed)

### Magento
- `default['magentostack']['config'][*]`
  - install.php related options, see https://github.com/AutomationSupport/magentostack/blob/master/definitions/magento_initial_configuration.rb
- `normal['magentostack']['mysql']['databases']['magento_database']`
  - create Magento DB and Magento DB users
- `default['magentostack']['download_url']` and `default['magentostack']['checksum']`
  - where to get Magento and the file checksum (faster re-converge)
- default['magentostack']['flavor'] = 'community' # could also be enterprise
  - controls if the stack should try to configure a full page cache or not

### NFS Server and client

# search query for discovery of nfs server
```
# Used to override the permitted client IPs on the nfs_server
node['magentostack']['nfs_server']['override_allow'] = ['1.2.3.4', '5.6.7.8']

# Used to override the NFS mount on clients, not used by default
node['magentostack']['nfs_server']['override_host'] = '1.2.3.4'

# where the export lives on the NFS server
node['magentostack']['nfs_server']['export_name'] = 'magento_media'
node['magentostack']['nfs_server']['export_root'] = '/export'

# how to search for an NFS server
node['magentostack']['nfs_server']['discovery_query'] = "tags:magentostack_nfs_server AND chef_environment:#{node.chef_environment}"

# clients
node['magentostack']['nfs_client']['mount_point'] = '/mnt/magento_media'
node['magentostack']['nfs_client']['symlink_target'] = 'media' # within /var/www/html/magento
```
### gluster

contains attributes used in setting up gluster, node the commented out section, it helps to actually hard code these IPs

### monitoring

controls how cloud_monitoring is used within magentostack

### php_fpm

shouldn't really be messed with

### redis

You can define a password for each redis instance(or for the single one) using the run_state attribute type.
This type prevents to store passwords on the node. The passwords will be used to set up the Redis instances and configure Magento.

Multiple redis instances
```
node.run_state['magentostack_redis_password_session'] = 'runstatepasswordsession'
node.run_state['magentostack_redis_password_object'] = 'runstatepasswordobject'
node.run_state['magentostack_redis_password_page'] = 'runstatepasswordpage'
```
Single redis instance
```
node.run_state['magentostack_redis_password_single'] = 'runstatepasswordsingle'
```

## Usage

### Suggested datastructures

Magento Admin:
```json
{
    "run_list": [
      "recipe[platformstack]",
      "recipe[magentostack::apache-fpm]",
      "recipe[magentostack::magento_install]",
      "recipe[magentostack::newrelic]",
      "recipe[magentostack::_find_mysql]",
      "recipe[magentostack::magento_configure]",
      "recipe[magentostack::magento_admin]",
      "recipe[magentostack::nfs_client]",
      "recipe[java::default]",
      "recipe[elkstack::agent]"
    ]
}
```

Magento Worker
```json
{
    "run_list": [
      "recipe[platformstack]",
      "recipe[magentostack::apache-fpm]",
      "recipe[magentostack::magento_install]",
      "recipe[magentostack::newrelic]",
      "recipe[magentostack::_find_mysql]",
      "recipe[magentostack::magento_configure]",
      "recipe[magentostack::nfs_client]",
      "recipe[java::default]",
      "recipe[elkstack::agent]"
    ]
}
```

Magento MySQL Master
```json
{
    "run_list": [
      "recipe[platformstack]",
      "recipe[magentostack::mysql_master]",
      "recipe[magentostack::mysql_holland]",
      "recipe[java::default]",
      "recipe[elkstack::agent]"
    ]
}
```

Magento Redis
```json
{
    "run_list": [
      "recipe[platformstack]",
      "recipe[magentostack::redis_single]",
      "recipe[magentostack::redis_configure]",
      "recipe[java::default]",
      "recipe[elkstack::agent]"
    ]
}
```

Magento Elkstack
```json
{
    "run_list": [
      "recipe[java::default]",
      "recipe[elkstack::cluster]",
      "recipe[elkstack::acl]"
    ]
}
```

Magento NFS Server
```json
{
    "run_list": [
      "recipe[apt]",
      "recipe[platformstack]",
      "recipe[magentostack::configure_disk]",
      "recipe[magentostack::nfs_server]",
      "recipe[java::default]",
      "recipe[elkstack::agent]"
    ]
}
```

## Users

To add users to the servers, you will need to set an attribute and add the user information to an encrypted or normal data bag.

`node['magentostack']['users'] = true`

Example user entry in data bag:

```json
{
    "jsmith": {
        "username": "jsmith",
        "shell": "/bin/bash",
        "sudo": true,
        "ssh_keys": "ssh-rsa AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA john.smith",
        "groups": ["apache", "wheel"]
    }
}
```

The supported options are: `comment uid home shell password system_user manage_home create_group ssh_keys ssh_keygen non_unique action username groups`


## New Relic Monitoring
To configure New Relic, make sure the `node['newrelic']['license']` attribute is set and include the `platformstack` cookbook in your run_list.  You can also run the `magentostack::newrelic` recipe for some more advanced monitors.

# Contributing
https://github.com/rackspace-cookbooks/contributing/blob/master/CONTRIBUTING.md

# Authors
Authors:: Rackspace <devops-chef@rackspace.com>

## License
```
# Copyright 2015, Rackspace Hosting
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
```
