require "bundler"
Bundler.require :default

load "const_stricter/tasks/lint.rake"

APP_GLOB = "dummy/*.rb"

# load app
path = File.expand_path(__dir__)
Dir.glob("#{path}/#{APP_GLOB}").each { |f| require f }

rake_task = Rake::Task["const_stricter:lint"]

rake_task.clear_prerequisites # reset requirement for environment
rake_task.invoke(APP_GLOB)
