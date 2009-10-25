# encoding: utf-8

class Station
  include DataMapper::Resource
  
  property :id, String, :length => 200, :key => true, :unique => true
  property :tracked_keyword, String, :length => 200
  property :tag_from_previous_collection, String, :length => 200
  property :station_was_started, Boolean, :default => false
  property :is_current_station, Boolean, :default => false
  timestamps :at
  
  belongs_to :tracked_listener
  has n, :broadcastable_programmes
  
  before :valid? do 
    self.attribute_set(:id, UUID.generate) if self.id.blank? 
  end
  
  def seed_station_with_programmes
    if !station_was_started
      tag_for_keyword = JSON.parse(ProgrammesCatalogue.related_tag_for_keyword(tracked_keyword))
      programmes_as_json = JSON.parse(ProgrammesCatalogue.programmes_for_tag(tag_for_keyword['id']))
      programmes_as_json.each do |programme_as_json|
        BroadcastableProgramme.build_with(programme_as_json).save
      end
      attribute_set(:tag_from_previous_collection, tag_for_keyword['id']) unless programmes_queue.empty?
    end
      
    # Create BroadcastableProgrammes that pending_broadcast == true
    # return true if seeding was successful
    # return false if seeding was unsuccessful
  end
  
  def programmes_queue
    BroadcastableProgramme.all(:pending_broadcast.eql => true, :order => [:created_at.asc])
  end
  
  def next_programme
    self.attribute_set(:station_was_started, true) unless  self.station_was_started
    
    result = programmes_queue.first
    result.update_attributes(:pending_broadcast => false)
    result
    # tracked_listener.change_current_station_to(self)
    #Get next from programmes_queue
    # if nothing, then seed_station_with_programmes
    #   on success, Get next from programmes_queue
    #   on failure, return nil
  end
  
  def to_json
    {"id" => self.id, "keyword" => self.keyword, "listener_id" => self.tracked_listener }.to_json
  end
end