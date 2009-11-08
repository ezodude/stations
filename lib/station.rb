# encoding: utf-8

class Station
  include DataMapper::Resource
  
  MAX_FOR_NEW_TAG_EXTRACTION = 5
  
  property :id, String, :length => 200, :key => true, :unique => true
  property :tracked_keyword, String, :length => 200
  property :tag_from_previous_collection, String, :length => 200
  property :station_was_started, Boolean, :default => false
  property :is_current_station, Boolean, :default => false
  property :last_played_at, Time, :nullable => true
  timestamps :at
  
  belongs_to :tracked_listener
  has n, :broadcastable_programmes
  
  before :valid? do 
    self.attribute_set(:id, UUIDTools::UUID.random_create) if self.id.blank? 
  end
  
  def seed_station_with_programmes(new_tag_id=nil)
    seed_tag_id = !station_was_started || new_tag_id.nil? ? \
      JSON.parse(ProgrammesCatalogue.related_tag_for_keyword(tracked_keyword))['id'] : new_tag_id
    
    programmes_as_json = JSON.parse(ProgrammesCatalogue.programmes_for_tag(seed_tag_id))
    programmes_as_json.each do |programme_as_json|
      BroadcastableProgramme.build_with(self, programme_as_json).save
    end
    self.update_attributes(:tag_from_previous_collection => seed_tag_id) unless programmes_queue.empty?
  end
  
  def programmes_queue
    BroadcastableProgramme.queued_pending_broadcasts_for(self)
  end
  
  def next_programme
    self.update_attributes(:station_was_started => true) unless self.station_was_started
    self.tracked_listener.change_current_station_to(self) 
    
    if programmes_queue.empty?
      new_tag_id = calculate_next_tag_id_for_station
      return nil unless new_tag_id
      seed_station_with_programmes(new_tag_id)
    end
    new_programme = programmes_queue.first
    new_programme.update_attributes(:pending_broadcast => false)
    self.update_attributes(:last_played_at => Time.now.utc)
    new_programme
  end
  
  def recent_programmes
    BroadcastableProgramme.broadcasted_programmes_for(self).slice(0, 6)
  end
  
  def to_json
    {"id" => self.id, "keyword" => self.tracked_keyword, "listener_id" => self.tracked_listener_id }.to_json
  end
  
private

  def calculate_next_tag_id_for_station
    number_of_brodcasted_programmes = BroadcastableProgramme.number_of_broadcasted_programmes_for(self)
    random_selector = number_of_brodcasted_programmes > MAX_FOR_NEW_TAG_EXTRACTION ? MAX_FOR_NEW_TAG_EXTRACTION : number_of_brodcasted_programmes
    5.times do
      tag_source = BroadcastableProgramme.broadcasted_programmes_for(self)[rand(random_selector)]
      new_tag_id = tag_source.get_tag_id_other_than(self.tag_from_previous_collection)
      return new_tag_id unless new_tag_id.nil? 
    end
    nil
  end
end