require 'rspec/core/rake_task'
require 'foodcritic'

desc 'Run Chef style checks'
FoodCritic::Rake::LintTask.new(:style) do |t|
    t.options = {
        :fail_tags => ['any']
    }
end

desc 'Run ChefSpec tests'
RSpec::Core::RakeTask.new(:spec)

desc 'Run Test Kitchen basic integration tests'
task 'kitchen-basic' do
    require 'kitchen'
    Kitchen.logger = Kitchen.default_file_logger
    config = Kitchen::Config.new
    config.instances.select { |i| i.name =~ /monolithic/ || i.name =~ /monitoring/ }.each do |instance|
        instance.test(:always)
    end
end

desc 'Run Test Kitchen integration tests'
task :kitchen do
    require 'kitchen'
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each do |instance|
        instance.test(:always)
    end
end

task :default => ['spec', 'style']
