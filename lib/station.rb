# encoding: utf-8

class Station
  include DataMapper::Resource
  
  property :id, String, :length => 200, :key => true, :unique => true
  property :tracked_keyword, String, :length => 200
  property :on_air_tag, String, :length => 200
  property :station_has_started, Boolean
  property :created_at, Time
  property :updated_at, Time
  
  belongs_to :tracked_listener
  # has n, :broadcastable_programmes
  
  before :valid? do 
    self.attribute_set(:id, UUID.generate) if self.id.blank? 
  end
  
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