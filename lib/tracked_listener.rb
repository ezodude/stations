# encoding: utf-8

class TrackedListener
  include DataMapper::Resource
  
  property :id, String, :length => 200, :key => true, :unique => true
  timestamps :at
  
  has n, :stations
  has n, :logged_listens
  
  def self.has_listener_with_station?(listener_id, keyword)
    unless listener = TrackedListener.get(listener_id)
      return false
    end
    num_stations_found = Station.count(:conditions => ['tracked_listener_id = ? and tracked_keyword = ?', listener.id, keyword])
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
  
  def log_listen(broadcastable_programme)
    LoggedListen.create(:tracked_listener => self, :broadcastable_programme => broadcastable_programme)
  end
  
  def recent_programmes_indexed_by_station(is_active_listening=true)
    return [] if self.logged_listens.count == 0
     
    logged_listens = self.logged_listens.all(:limit => 6, :order => [:created_at.desc])
    filtered_logged_listens = filter_by_listening_state(logged_listens, is_active_listening)
    return [] if filtered_logged_listens.empty?
    
    stations_and_programmes = filtered_logged_listens.collect { |logged_listen| logged_listen.station_to_programme }
    collate_recent_programmes_indexed_by_stations(stations_and_programmes)
  end
  
  def to_json
    {:id => id}.to_json
  end

private
  
  def filter_by_listening_state(logged_listens, is_active_listening)
    logged_listens_count = logged_listens.size
    result = if is_active_listening
            logged_listens_count > 1 ? logged_listens.slice(1, logged_listens_count - 1) : []
          else
            logged_listens_count > 1 ? logged_listens.slice(0, logged_listens_count - 1) : logged_listens.slice(0,1)
          end
    result
  end
  
  def collate_recent_programmes_indexed_by_stations(stations_and_programmes)
    last_station_seen = stations_and_programmes[0][0]
    programmes, result = [], []
    stations_and_programmes.each do |station, programme|
      if last_station_seen == station
        programmes << programme
      else
        result << {'station' => last_station_seen, 'programmes' => programmes}
        programmes = [programme]
        last_station_seen = station
      end
    end
    result << {'station' => last_station_seen, 'programmes' => programmes}
    result
  end
end