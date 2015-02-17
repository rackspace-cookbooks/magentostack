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
