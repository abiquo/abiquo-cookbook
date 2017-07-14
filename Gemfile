source 'https://rubygems.org'

gem 'chef', '~> 12.16.42'
# Lock chef-zero to a version that supports Ruby 2.2 
gem 'chef-zero', '~> 5.3.2'

gem 'berkshelf', '~> 5.4.0'
# Required by Berkshelf to resolve dependenxies
gem 'dep_selector', '~> 1.0.5'

gem 'foodcritic', '~> 10.3.1', group: :lint
gem 'cookstyle', '~> 2.0.0', group: :lint
gem 'chefspec', '~> 5.3.0', group: :unit
gem 'mysql2', '~> 0.4.4', group: :unit
gem 'hashie', '<= 3.4.4', group: :unit
gem 'nio4r', '<= 1.2.1', group: :unit

group :integration do
  gem 'serverspec', '~> 2.38.0'
  gem 'test-kitchen', '~> 1.15.0'
  gem 'kitchen-vagrant', '~> 0.20.0'
end
