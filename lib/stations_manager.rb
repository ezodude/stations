# encoding: utf-8
#------------------------------------------------------------------------------------------------------------
class TrackedListener
  include DataMapper::Resource
  
  property :id, String, :length => 200, :key => true, :unique => true
  property :created_at, Time
  property :updated_at, Time
  
  has n, :stations
  
  def has_station_for?(keyword)
  end
  
  def recent_stations
    # last 3 stations
  end
  
  def create_station_for?(keyword)
    
  end
end

class Station
  include DataMapper::Resource
  
  property :id, String, :length => 200, :key => true, :unique => true
  property :keyword, String, :length => 200, :unique => true
  property :on_air_tag, String, :length => 200
  property :new_station, boolean
  property :created_at, Time
  property :updated_at, Time
  
  belongs_to :tracked_listener
  has n, :broadcastable_programmes
  
  def seed_station_with_programmes
    # Create BroadcastableProgrammes that pending_broadcast == true
    # return true if seeding was successful
    # return false if seeding was unsuccessful
  end
  def programmes_queue
    # BroadcastableProgrammes that are pending
  end
  def next_programme
    #Get next from programmes_queue
    # if nothing, then seed_station_with_programmes
    #   on success, Get next from programmes_queue
    #   on failure, return nil
  end
end

class BroadcastableProgramme
  include DataMapper::Resource
  
  property :id, Serial
  property :programmme_id, String, :length => 200
  property :programmme_audio_uri, Text, :lazy => false
  property :programmme_title, Text, :lazy => false
  property :programmme_summary, Text
  property :programmme_tags, Text, :lazy => false #tag_id::title,tag_id::title
  property :pending_broadcast, Boolean
  
  belongs_to :station
end


class Listener
  attr_reader :id, :stations
  def self.build(listener_id, all_stations)
  end
  
  def initialize(listener_id)
    @id, @stations = listener_id, []
  end
  
  def add_station(keyword)
    station = Station.build(keyword)
    @stations << station
  end
  
  def recent_stations; end
  def has_station_for?(keyword)
    
  end
  def to_json
    {'id' => id, 'stations' => stations}
  end
end

class Station
  attr_reader :id, :keyword, :created_at
  
  def self.build(keyword)
    Station.new(UUID.generate, keyword, [], Time.now.utc)
  end
  
  def initialize(id, keyword, sent_programmes, created_at)
    @id, @keyword, @sent_programmes, @created_at = id, keyword, sent_programmes, created_at
  end
  
  def seed_station_with_programmes; end
  def programmes_queue; end
  def sent_programmes # [{:date_requested => date_time, :uri => uri, :theme_id => theme_id}]
    @sent_programmes
  end 
  def feedback_for(uri, rating); end
  def reactivation_date; end # this is updated with the last datetime the subscription was requested by a listener
  def next_programme; end
  def to_json
    {'id' => id, 'keyword' => keyword, 'sent_programmes' => sent_programmes, 'created_at' => created_at.to_json}.to_json
  end
end

class StationsJsonStore
  def initialize(store_path='stations.json')
    @store_path = store_path
  end
  
  def load_json
    json = begin
      File.read(@store_path)
    rescue Errno::ENOENT
      '{}'
    end
    
    json_data = JSON.load(json)
    stations = json_data.inject({}) do |loaded_stations, raw_record|
      record = JSON.parse(raw_record)
      station = Station.new(record['id'], record['keyword'], record['sent_programmes'], Time.parse(record['created_at']).utc)
      loaded_stations.update(station.id => station)
    end
  end
  
  def save_json(stations)
    json = stations.map { |(id, station)| station.to_json }.to_json
    File.open(@store_path, 'w') { |f| f.write(json) }
  end
end

#------------------------------------------------------------------------------------------------------------

class StationsManager
  attr_reader :stations
  
  def self.load
    obj = self.new
    obj.load
    return obj
  end
  
  def initialize
    @stations_store = StationsJsonStore.new(File.join(Dir.getwd, 'data/stations.json'))
    @listeners_store = StationsJsonStore.new(File.join(Dir.getwd, 'data/listeners.json'))
  end
  
  def load
    @stations = @stations_store.load_json
    @listeners = @listeners_store.load_json
  end
  
  def station_for(listener_id, keyword)
  end
  
  def remove_stations(*ids)
    ids.flatten.each do |id| @stations.delete(id) end
    @stations_store.save_json(@stations)
  end
  
  def append_stations(*stations)
    stations.flatten.each { |station| @stations[station.id] = station }
    @stations_store.save_json(@stations)
  end
  
  def remove_listeners(*ids)
    ids.flatten.each do |id| @stations.delete(id) end
    @stations_store.save_json(@stations)
  end
  
  def append_listeners(*listeners)
    stations.flatten.each { |station| @stations[station.id] = station }
    @stations_store.save_json(@stations)
  end
end

class Listener
  attr_reader :id, :stations
  def self.build(listener_id, all_stations)
  end
  
  def initialize(listener_id)
    @id, @stations = listener_id, []
  end
  
  def add_station(keyword)
    station = Station.build(keyword)
    @stations << station
  end
  
  def recent_stations; end
  def has_station_for?(keyword)
    
  end
  def to_json
    {'id' => id, 'stations' => stations}
  end
end

class Station
  attr_reader :id, :keyword, :created_at
  
  def self.build(keyword)
    Station.new(UUID.generate, keyword, [], Time.now.utc)
  end
  
  def initialize(id, keyword, sent_programmes, created_at)
    @id, @keyword, @sent_programmes, @created_at = id, keyword, sent_programmes, created_at
  end
  
  def seed_station_with_programmes; end
  def programmes_queue; end
  def sent_programmes # [{:date_requested => date_time, :uri => uri, :theme_id => theme_id}]
    @sent_programmes
  end 
  def feedback_for(uri, rating); end
  def reactivation_date; end # this is updated with the last datetime the subscription was requested by a listener
  def next_programme; end
  def to_json
    {'id' => id, 'keyword' => keyword, 'sent_programmes' => sent_programmes, 'created_at' => created_at.to_json}.to_json
  end
end

class StationsJsonStore
  def initialize(store_path='stations.json')
    @store_path = store_path
  end
  
  def load_json
    json = begin
      File.read(@store_path)
    rescue Errno::ENOENT
      '{}'
    end
    
    json_data = JSON.load(json)
    stations = json_data.inject({}) do |loaded_stations, raw_record|
      record = JSON.parse(raw_record)
      station = Station.new(record['id'], record['keyword'], record['sent_programmes'], Time.parse(record['created_at']).utc)
      loaded_stations.update(station.id => station)
    end
  end
  
  def save_json(stations)
    json = stations.map { |(id, station)| station.to_json }.to_json
    File.open(@store_path, 'w') { |f| f.write(json) }
  end
end

class ListenersJsonStore
  def initialize(store_path='listeners.json')
    @store_path = store_path
  end
  
  def load_json
    json = begin
      File.read(@store_path)
    rescue Errno::ENOENT
      '{}'
    end
    
    json_data = JSON.load(json)
    listeners = json_data.inject({}) do |loaded_listeners, raw_record|
      record = JSON.parse(raw_record)
      station = Station.new(record['id'], record['keyword'], record['sent_programmes'], Time.parse(record['created_at']).utc)
      loaded_listeners.update(station.id => station)
    end
  end
  
  def save_json(stations)
    json = stations.map { |(id, station)| station.to_json }.to_json
    File.open(@store_path, 'w') { |f| f.write(json) }
  end
end