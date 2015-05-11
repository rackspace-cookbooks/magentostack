source "https://supermarket.getchef.com"

metadata

group :integration do
  cookbook 'disable_ipv6', path: 'test/fixtures/cookbooks/disable_ipv6'
  cookbook 'wrapper', path: 'test/fixtures/cookbooks/wrapper'
  cookbook 'apt'
  cookbook 'yum'
end

# Until https://github.com/newrelic-platform/newrelic_plugins_chef/pull/29 is merged
cookbook 'newrelic_plugins', git: 'git@github.com:rackspace-cookbooks/newrelic_plugins_chef.git'

# pin newrelic until the releases stabalize
cookbook 'newrelic', '<= 2.10'

# pin git until https://github.com/chef-cookbooks/mysql/issues/328 truly resolved
cookbook 'git', '= 4.1.0'
