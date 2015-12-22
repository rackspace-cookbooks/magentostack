source 'https://rubygems.org'

group :lint do
  gem 'foodcritic', '>= 4.0'
  gem 'foodcritic-rackspace-rules', '>= 1.3.2'
  gem 'rubocop', '~> 0.33.0', require: false
end

group :unit do
  gem 'berkshelf', '~> 4'
  gem 'chefspec', '>= 4.2'
  gem 'chef-sugar'
  gem 'chef', '>= 12.4.1'
end

group :kitchen_common do
  gem 'test-kitchen'
end

group :kitchen_vagrant do
  gem 'kitchen-vagrant'
  gem 'vagrant-wrapper'
end

group :kitchen_rackspace do
  gem 'kitchen-rackspace'
end

group :development do
  gem 'growl'
  gem 'rb-fsevent'
  gem 'guard'
  gem 'guard-kitchen'
  gem 'guard-foodcritic'
  gem 'guard-rubocop'
  gem 'fauxhai'
  gem 'pry-nav'
end
