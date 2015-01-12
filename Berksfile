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

# 0.9.1 is not available in the market, but we need it for chefspec and lib/matchers
# it's not a major problem if the wrapper cookbook has 0.9.0 as 0.9.1 is only required for tests
cookbook 'ark', git:'https://github.com/burtlo/ark.git', ref: '1f7c092ffe80073409bce7fa851346fb076a259f'

# until https://github.com/opscode-cookbooks/openssl/pull/11
cookbook 'openssl', git: 'https://github.com/racker/openssl.git'

cookbook 'kibana', git: 'git@github.com:lusis/chef-kibana.git', branch: 'KIBANA3'

# Until https://github.com/newrelic-platform/newrelic_plugins_chef/pull/29 is merged
cookbook 'newrelic_plugins', git: 'git@github.com:rackspace-cookbooks/newrelic_plugins_chef.git'
