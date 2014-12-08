source "https://supermarket.getchef.com"

metadata

cookbook 'rackops_rolebook', git: 'git@github.com:rackops/rackops_rolebook.git'

group :integration do
  cookbook 'disable_ipv6', path: 'test/fixtures/cookbooks/disable_ipv6'
  cookbook 'wrapper', path: 'test/fixtures/cookbooks/wrapper'
  cookbook 'apt'
  cookbook 'yum'
end

# Fixes in master@HEAD, but not latest release 2.2.4
# This line may be removed once a newer version has been released
cookbook 'redisio', git:'git@github.com:brianbianco/redisio.git'

# 0.9.1 is not available in the market, but wee need it for chefspec and lib/matchers
# it's not a major problem if the wrapper cookbook has 0.9.0 as 0.9.1 is only required for tests
cookbook 'ark', git:'git@github.com:burtlo/ark.git', ref: '1f7c092ffe80073409bce7fa851346fb076a259f'

# until https://github.com/opscode-cookbooks/openssl/pull/11
cookbook 'openssl', git: 'git@github.com:racker/openssl.git'
