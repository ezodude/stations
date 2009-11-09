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
require 'logged_listen'

BroadcastableProgramme.auto_upgrade!
Station.auto_upgrade!
TrackedListener.auto_upgrade!
LoggedListen.auto_upgrade!

require 'podcast'
require 'tag'
require 'classification'
Podcast.auto_upgrade!
Tag.auto_upgrade!
Classification.auto_upgrade!