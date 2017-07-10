require 'rspec/core/rake_task'

desc 'Run Foodcritic style checks'
task :foodcritic do
  require 'foodcritic'
  FoodCritic::Rake::LintTask.new(:foodcritic) do |t|
    t.options = { fail_tags: ['any'] }
  end
end

desc 'Run ChefSpec tests'
RSpec::Core::RakeTask.new(:chefspec)

desc 'Run Cookbook style checks'
task :cookstyle do
  require 'cookstyle'
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:cookstyle) do |config|
    config.options = %w(-DSE)
  end
end

desc 'Run Test Kitchen basic integration tests'
task 'kitchen-basic' do
  require 'kitchen'
  Kitchen.logger = Kitchen.default_file_logger
  @loader = Kitchen::Loader::YAML.new(local_config: ENV['KITCHEN_LOCAL_YAML'])
  config = Kitchen::Config.new(loader: @loader)
  config.instances.select { |i| i.name =~ /monolithic/ || i.name =~ /frontend/ || i.name =~ /monitoring/ }.each do |instance|
    instance.test(:always)
  end
end

desc 'Run Test Kitchen integration tests'
task :kitchen do
  require 'kitchen'
  Kitchen.logger = Kitchen.default_file_logger
  @loader = Kitchen::Loader::YAML.new(local_config: ENV['KITCHEN_LOCAL_YAML'])
  Kitchen::Config.new(loader: @loader).instances.each do |instance|
    instance.test(:always)
  end
end

task default: %w(chefspec foodcritic cookstyle)
