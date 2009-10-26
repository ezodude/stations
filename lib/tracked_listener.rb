# encoding: utf-8

class TrackedListener
  include DataMapper::Resource
  
  property :id, String, :length => 200, :key => true, :unique => true
  timestamps :at
  
  has n, :stations
  
  def self.has_listener_with_station?(listener_id, keyword)
    p [:listener_id, listener_id]
    p [:keyword, keyword]
    
    unless listener = TrackedListener.get(listener_id)
      p [:unless_listener, 'yes']
      return false
    end
    num_stations_found = Station.count(:conditions => ['tracked_listener_id = ? and tracked_keyword = ?', listener.id, keyword])
    p [:num_stations_found, num_stations_found]
    num_stations_found > 0
  end
  
  def self.track_with_station(listener_id, keyword)
    raise RuntimeError.new("There is no progamme content available for [#{keyword}].") unless ProgrammesCatalogue.related_tag_for_keyword(keyword)
    
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
  
  def change_current_station_to(candidate)
    candidate.update_attributes(:is_current_station => true) and return if current_station.nil?
    return if current_station == candidate
    
    if current_station.update_attributes(:is_current_station => false)
      candidate.update_attributes(:is_current_station => true)
    end
  end
  
  def current_station
    Station.first(:conditions => ['tracked_listener_id = ? and is_current_station = ?', self.id, true])
  end
end