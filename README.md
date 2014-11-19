# magentostack

## Supported Platforms

- CentOS 6.5
- Ubuntu 12.04
- Ubuntu 14.04

## Requirements

### Cookbooks

- `apache2`
- `apt`
- `build-essential`
- `chef-sugar`
- `git`
- `openssl`
- `php-fpm`
- `platformstack`
- `yum`
- `yum-ius`
- `yum-epel`

## Recipes

### default
- what it does
  - nothing
- toggles
  - nothing

### apache-fpm
This recipe sets Apache2 configuration so you can deploy your Magento code.
- what it does
  - configures Apache with PHP FPM
  - enables magento required modules
  - create a self-signed certificate if node['magentostack']['web']['ssl_autosigned'] (default to true)
  - create a Vhost for Magento (non-SSL)
  - create a Vhost for Magento (SSL)
- toggles
  - certificate generation node['magentostack']['web']['ssl_autosigned']

> apache2::mod_fastcgi doesn't allow to compile mod_Fastcgi from source, therefore it will not use the mod_fastcgi patched version. It means Ubuntu with Magento CE <1.9 or EE < 1.14 might have some bugs. [References](http://www.magentocommerce.com/boards/m/viewthread/229253/)

### gluster
- what it does
  - sets up glusterfs based on the `node['rackspace_gluster']['config']['server']['glusters']` attribute
    - this may involve some manual setup, it is glusterfs afterall

### mysql_add_drive
- what it does
  - formats /dev/xvde1 and will prepare it for the mysql datadir.
  - creates the mysql user and manages the /var/lib/mysql mountpoint

### mysql_base
- what it does
  - sets a random root mysql password if the default password would normally be set
  - sets up mysql
  - sets up a holland user if `node['holland']['enabled']`
  - sets up a monitoring mysql user and monitor if `node['platformstack']['cloud_monitoring']['enabled']`
  - allow app nodes in the environment to attempt to connect
  - auto-generates mysql databases and assiciated users/passwords for sites installed (can be disabled)
  - installs magentostack specific databases (will autogenerate the user and password if needed still)
- toggles
  -  `node['magentostack']['db-autocreate']['enabled']` controls database autocreation at a global level
  -  if the site has the `db_autocreate` attribute, it will control database autocreation for that site
- info
  - auto-generated databases are based on site name and port number the site is on, same for username

### mysql_holland
-  what it does
  -  installs holland
  -  will set up a backup job based on if you are running as a slave or not

### mysql_master
- what it does
  - sets up mysql master (runs the mysql_base recipe as well)
  - will allow slaves to connect (via iptables)

### mysql_slave
- what it does
  - sets up the mysql slave (runs the mysql_base recipe as well)
  - allows the master to connect (via iptables)

### newrelic
- what it does
  - sets up newrelic and the php agent for newrelic

### redis_single
- what it does
  - configures a standalone redis server in `node['redisio']['servers']`
  - redis server bound to `node['magentostack']['redis']['bind_port_single']`
  - tags node with `magentostack_redis` and `magentostack_redis_single` for discovery

### redis_object, redis_page, redis_session
- what it does
  - configures a redis server in `node['redisio']['servers']`
  - instance is bound to `node['magentostack']['redis']['bind_port_X']` where X is object, page, or session
  - tags node with `magentostack_redis` and `magentostack_redis_X` for later discovery

### redis_sentinel
- what it does
  - sets up redis sentinel bound to `node['magentostack']['redis']['bind_port_sentinel']`
  - uses discovery in `libraries/util.rb` to find all redis servers in current chef environment
  - discovery is based on tags and chef environment, see `node['magentostack']['redis']['discovery_query']` to override
  - determines a master (using tags) in this order: redis_session.rb, redis_single.rb, `none`
  - assumes a session store is the most important to monitor (upstream only supports configuring sentinel to monitor one master)

### redis_configure
- what it does
  - shortcut to run all of the redisio recipes needed to install & configure redis
  - should be used after any calls to the redis_(single/object/page/session/sentinel) recipes

### varnish
- what it does
  - allows clients to connect to the varnish port (via iptables)
  - enables the cloud monitoring plugin for varnish
  - sets the default backend port to the first useful port it can find
  - sets up varnish if for multi backend load ballancing per vhost/port combination
- toggles
  - `node['varnish']['multi']` controls if varnish is simple or complex (multi backend or not)
    - it is also controled by if any backend nodes are found

## Data_Bags

No Data_Bag configured for this cookbook

## Attributes

### default

- `default['magentostack']['newrelic']['application_monitoring'] = ''`
  - controls if we allow newrelic to to do application monitoring
    - is set to `'true'` in the newrelic recipe
- `default['magentostack']['ini']['cookbook'] = 'magentostack'`
  - sets where the `/etc/magentostack.ini` template is sourced from
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
- `default['magentostack']['web']['ssl_key']` and `default['magentostack']['web']['ssl_cert']`
  - where are the certificates and keys (might be useful when disabling self-signed)

### gluster

contains attributes used in setting up gluster, node the commented out section, it helps to actually hard code these IPs

### monitoring

controls how cloud_monitoring is used within magentostack

### php_fpm

shouldn't really be messed with

### varnish
- `default['magentostack']['varnish']['multi'] = true`
  - allows us to use more complex logic for the varnish configuration
- `default['magentostack']['varnish']['backend_nodes'] = []`
  - a list of nodes to use for backends. if empty or nil, search is the default behavior

## Usage

### useful datastructures

### magentostack

```
- MySQL DB Single Node:
```json
{
    "run_list": [
      "recipe[platformstack::default]",
      "recipe[rackops_rolebook::default]",
      "recipe[magentostack::mysql_base]"
    ]
}
```

- MySQL DB Master Node:
```json
{
    "run_list": [
      "recipe[platformstack::default]",
      "recipe[rackops_rolebook::default]",
      "recipe[magentostack::mysql_master]"
    ]
}
```

- MySQL DB Slave Node:
```json
{
    "run_list": [
      "recipe[platformstack::default]",
      "recipe[rackops_rolebook::default]",
      "recipe[magentostack::mysql_slave]"
    ]
}
```

## New Relic Monitoring

To configure New Relic, make sure the `node['newrelic']['license']` attribute is set and include the `platformstack` cookbook in your run_list.  You can also run the `magentostack::newrelic` recipe for some more advanced monitors.


# Contributing

https://github.com/rackspace-cookbooks/contributing/blob/master/CONTRIBUTING.md


# Authors
Authors:: Matthew Thode <matt.thode@rackspace.com>
