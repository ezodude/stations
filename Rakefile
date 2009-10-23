require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
 
Dir["#{File.dirname(__FILE__)}/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

task :init_env do
  $:.unshift File.join(File.dirname(__FILE__), "config")
  $:.unshift File.join(File.dirname(__FILE__), "lib/podbase")
  require "#{File.dirname(__FILE__)}/config/initialise"
end

task :init_test_env do
  $:.unshift File.join(File.dirname(__FILE__), "config")
  $:.unshift File.join(File.dirname(__FILE__), "lib/podbase")
  ENV['RUNNING_CONTEXT'] = 'test'
  require "#{File.dirname(__FILE__)}/config/initialise"
end
