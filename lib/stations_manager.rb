require "rubygems"
require "json"
require "time"
require "uuid"

# class ThemeMapping
#   def self.load(theme_mappings_data='theme_mappings.json'); end
#   def self.theme_mapping_for(keyword); end
#   def theme; end
#   def programmes; end
#   def to_json; end
# end

# @theme_mappings = [
#   {:it_conversations => ["http://localhost:3000/sample_programme/test.mp3"] },
#   {:it => ["http://localhost:3000/sample_programme/test.mp3"] },
#   {:information_technology => ["http://localhost:3000/sample_programme/test.mp3"] },
#   {:technometria => ["http://localhost:3000/sample_programme/test.mp3"] },
#   {:phil_windley => ["http://localhost:3000/sample_programme/test.mp3"] },
#   {:dave_winer => ["http://localhost:3000/sample_programme/test.mp3"] },
#   {:tweeting_the_news => ["http://localhost:3000/sample_programme/test.mp3"] },
#   {:the_internet_and_the_world_wide_web => ["http://localhost:3000/sample_programme/test.mp3"] },
#   {:media => ["http://localhost:3000/sample_programme/test.mp3"] },
#   {:personal_technology => ["http://localhost:3000/sample_programme/test.mp3"] },
#   {:date_20090615 => ["http://localhost:3000/sample_programme/test.mp3"] },
# ]

# class Programme #(Podcast??)
#   def self.load(programmes_data='programmes.json'); end
#   def self.programme_for(uri); end
#   def uri; end
#   def title; end
#   def themes; end
#   def to_json; end
# end
# @programmes = [ 
#   #programme
#   {"http://localhost:3000/sample_programme/test.mp3" =>  
#     [:it_conversations, :it, :information_technology, :technometria, :phil_windley, :dave_winer, 
#       :tweeting_the_news, :the_internet_and_the_world_wide_web, :media, :personal_technology, :date_20090615]
#   },
# ]
  
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