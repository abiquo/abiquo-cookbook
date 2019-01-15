source 'https://rubygems.org'

gem 'chef', '~> 14.8'
gem 'chef-zero', '~> 14.0'

gem 'berkshelf', '~> 7.0'

gem 'foodcritic', '~> 15.1', group: :lint
gem 'cookstyle', '~> 3.0.2', group: :lint
## Chefspec >= 7.3 breaks with definitions
##   https://github.com/sous-chefs/apache2/issues/588
##   https://github.com/chefspec/chefspec/issues/926
gem 'chefspec', '<= 7.2.1', group: :unit
gem 'mysql2', '~> 0.4.9', group: :unit
gem 'dbus-systemd', '~> 1.1', group: :unit

group :integration do
  gem 'serverspec', '~> 2.41'
  gem 'test-kitchen', '~> 1.24'
  gem 'kitchen-vagrant', '~> 1.3'
end
