$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib/podbase')

require 'dm-core'
require 'dm-validations'

local_sqlite3_file = "sqlite3://data/#{ENV['RUNNING_CONTEXT'] == 'test' ? "test." : ''}stations.sqlite3"

DataMapper.setup(:default, ENV['DATABASE_URL'] || local_sqlite3_file)

require 'podcast'
require 'tag'
require 'classification'

DataMapper.auto_migrate!