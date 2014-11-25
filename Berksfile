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
