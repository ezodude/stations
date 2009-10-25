$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib/podbase')

require 'dm-core'
require 'dm-aggregates'
require 'dm-validations'
require 'dm-timestamps'

local_sqlite3_file = "sqlite3://data/#{ENV['RUNNING_CONTEXT'] == 'test' ? "test." : ''}stations.sqlite3"

DataMapper.setup(:default, ENV['DATABASE_URL'] || local_sqlite3_file)

require 'broadcastable_programme'
require 'station'
require 'tracked_listener'

BroadcastableProgramme.auto_migrate! unless BroadcastableProgramme.storage_exists?
Station.auto_migrate! unless Station.storage_exists?
TrackedListener.auto_migrate! unless TrackedListener.storage_exists?

require 'podcast'
require 'tag'
require 'classification'
Podcast.auto_migrate! unless Podcast.storage_exists?
Tag.auto_migrate! unless Tag.storage_exists?
Classification.auto_migrate! unless Classification.storage_exists?