magentostack CHANGELOG
==================

2.2.3
-----
- Fix a missing underscore in an attribute name (#232)
- Don't open portmapper to anything but real NFS clients that need it (#238)

2.2.2
-----
- Correctly deploy SSL chain file #233, #234

2.2.1
-----
- Add execution logic to varnish_cookbook.
- Use helper method to read values for magento_installer

2.2.0
-----
- Allow additional SSH wrapper settings #227
- Partial search didn't return enough #228
- Fix style errors #225
- Add attribute to modify fastcgi AddHandler directive #218
- removing unused attributes #218

2.1.1
-----
- Block .svn and .git directories in Apache vhost, #220

2.1.0
-----
- Feature: add users from databag
- Feature: add cloud monitoring
- Fix: Update path; mysqld is apparently now in /usr/sbin
- Fix: add missing users dependency

2.0.8
-----
- Open up the port for varnish.

2.0.7
-----
- Use existing node.run_state values if they are already set. We should clean this up in general, more, but this is a quick fix for a specific issue I ran into.
- Allow git branch to be specified when deploying via Git.

2.0.6
-----
- Support passing 'timeout' to the subversion resource for deployment type 'svn'

2.0.5
-----
- Support passing svn_info to the subversion resource for deployment type 'svn'

2.0.4
-----
- Grab the crypt key from run_state as well as node attributes.
- Add support for SVN deploy method

2.0.3
-----
- Do not pre-create magento dir if a git checkout is intended.

2.0.2
-----
- Feature: Add option to enable git submodules when using git as the `install_method`.

2.0.1
-----
- We should not pass `false` to the file resource, while configuring the Varnish secret.
  This prevents that while still guarding against a missing value.

2.0.0
-----
- Release new version, after moving repository and removing dependency pinning.

1.1.2
-----
- Ensure we list most relevant dependencies first, to make Berkshelf solve for them first (#173)

1.1.1
-----
- Keep consistent naming for encryption key. (#163)

1.1.0
-----
- Allow ES and NFS data to live under one mount (#161)

1.0.0
-----
- Add split read and write behavior, move some attribute namespaces (#177)

0.0.3
-----
- Add option to create DNS entry for cloud load balancer (#153)

0.0.1
-----
- Add elkstack back in to the build for checkmate (#152)
- Add kibana username and password to checkmate blueprints/map
- Add redis cleanup cronjob to admin node (#151)
- Default to empty string for database prefix (#149)
- Add mbstring package (#146)
- Newer chef version requirements (#145)
- Test cloud files install method, works flawlessly
- Split install methods into ark, cloudfiles, or none
- Add 'cloudfiles' install method, used rackspacecloud LWRPs
- Adjust configuration of magento to write out shell script with configuration options instead of calling it inline.
- Guard call to `mysql-multi::_find_master` (we probably should not be using it, opened #30 to discuss), call `mysql-multi::master` instead of base so we get a node we can find later.
- Add 'expanded' default recipe in wrapper that converges separate redis instances instead of a single one. This should now handle any configuration of runlist thrown at it.
- Add redisio as a direct dependency, and in Berksfile until release. redis-multi is too simplistic for this deployment, and some bugs are fixed in git that aren't released yet
- Add separate redis recipes for session store and page, object caches and their slaves
- Add redis sentinel recipes that find the right instance
- Add expanded default recipe, that converges individual components (like 3 redis vs. single redis)
- Add a redis discovery recipe that finds any redis instances in the same chef environment
- Add iptables to `::redis_configure` recipe
- Add tags to node before saving node, so tags are findable on node.save
- Add library with methods to discover redis instances, find master instances, recompute redis attributes, and get the best IP for a node from its name
- Add Apache vhost, cleanup testing for things we didn't converge
- Remove return on missing attribute
- Could not pass testing with listen_ports mixing node.default and node.set
- Remove template for magentostack.ini, since actual source file was already removed
- Switch to node.deep_fetch with additional guards, since some of the attributes were removed here
- s/phpstack/magentostack/g everywhere
