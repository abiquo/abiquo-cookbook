source 'https://rubygems.org'

gem 'chef', '~> 12.7.2'
gem 'berkshelf', '~> 4.0.1'

gem 'foodcritic', '~> 7.0.0', :group => :lint
gem 'rubocop', '~> 0.42.0', :group => :lint
gem 'chefspec', '~> 4.4.0', :group => :unit
gem 'mysql2', '~> 0.4.4', :group => :unit
gem 'hashie', '<= 3.4.4', :group => :unit

group :integration do
    gem 'serverspec', '~> 2.24.1'
    gem 'test-kitchen', '~> 1.4.2'
    gem 'kitchen-vagrant', '~> 0.19.0'
end
