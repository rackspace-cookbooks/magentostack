source "https://supermarket.getchef.com"

metadata

group :integration do
  cookbook 'disable_ipv6', path: 'test/fixtures/cookbooks/disable_ipv6'
  cookbook 'wrapper', path: 'test/fixtures/cookbooks/wrapper'
  cookbook 'apt'
  cookbook 'yum'
end

# Fixes in master@HEAD, but not latest release 2.2.4
# This line may be removed once a newer version has been released
cookbook 'redisio', git:'https://github.com/brianbianco/redisio.git'

# Until https://github.com/newrelic-platform/newrelic_plugins_chef/pull/29 is merged
cookbook 'newrelic_plugins', git: 'git@github.com:rackspace-cookbooks/newrelic_plugins_chef.git'

cookbook 'elkstack'
# monit and chef-provisioning is "suggested" and Berkshelf will see that and add it to the lock file
# but not install it; causing it to fail on `upload`
cookbook 'monit'
cookbook 'chef-provisioning'

# pin newrelic until the releases stabalize
cookbook 'newrelic', '<= 2.10'

# pin git until https://github.com/chef-cookbooks/mysql/issues/328 truly resolved
cookbook 'git', '= 4.1.0'
