# encoding: utf-8

class TrackedListener
  include DataMapper::Resource
  
  property :id, String, :length => 200, :key => true, :unique => true
  property :created_at, Time
  property :updated_at, Time
  
  has n, :stations
  
  def self.has_listener_with_station?(listener_id, keyword)
    return false unless listener = TrackedListener.get(listener_id)
    Station.count(:conditions => ['tracked_listener_id = ? and tracked_keyword = ?', listener.id, keyword]) > 0
  end
  
  def self.track_with_station(listener_id, keyword)
    obj = self.get(listener_id)
    obj = obj.blank? ? self.new(:id => listener_id) : obj
    
    if has_listener_with_station?(listener_id, keyword)
      raise RuntimeError.new("Tracked listener with id[#{listener_id}] already has a station for keyword [#{keyword}].")
    end
    
    obj.stations << Station.new(:tracked_keyword => keyword)
    obj.save ? obj : nil
  end
  
  def station_for_keyword(keyword='')
    Station.first(:conditions => ['tracked_listener_id = ? and tracked_keyword = ?', self.id, keyword])
  end
  
  # def recent_stations
  #   # last 3 stations
  # end
  # 
end