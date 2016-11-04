require 'rspec/core/rake_task'
require 'foodcritic'

desc 'Run Chef style checks'
FoodCritic::Rake::LintTask.new(:style) do |t|
  t.options = {
    fail_tags: ['any']
  }
end

desc 'Run ChefSpec tests'
RSpec::Core::RakeTask.new(:spec)

desc 'Run Test Kitchen basic integration tests'
task 'kitchen-basic' do
  require 'kitchen'
  Kitchen.logger = Kitchen.default_file_logger
  @loader = Kitchen::Loader::YAML.new(local_config: ENV['KITCHEN_LOCAL_YAML'])
  config = Kitchen::Config.new(loader: @loader)
  config.instances.select { |i| i.name =~ /monolithic/ || i.name =~ /monitoring/ }.each do |instance|
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

desc 'Run Ruby style checks'
task :rubocop do
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new do |config|
    config.options = %w(-DSE)
  end
end

task default: %w(spec style rubocop)
