# encoding: utf-8

class BroadcastableProgramme
  include DataMapper::Resource
  
  property :id, Serial
  property :prog_id, String, :length => 200, :nullable => false
  property :prog_audio_uri, Text, :lazy => false, :nullable => false
  property :prog_title, Text, :lazy => false, :nullable => false
  property :prog_summary, Text
  property :prog_tags, Text, :lazy => false, :nullable => false #tag_id::title,tag_id::title
  property :prog_published_at, Date, :nullable => true
  property :prog_source_uri, Text, :lazy => false, :nullable => true
  property :pending_broadcast, Boolean, :default => true
  timestamps :at
  
  belongs_to :station
  
  def self.build_with(station, jsonified_programme)
    parsed_programme = JSON.parse(jsonified_programme)
    self.new(:station => station, :prog_id => parsed_programme['id'], :prog_audio_uri => parsed_programme['audio_uri'], 
              :prog_title => parsed_programme['title'], :prog_summary => parsed_programme['summary'], :prog_tags => parsed_programme['tags'], 
              :prog_published_at => parsed_programme['published_at'], :prog_source_uri => parsed_programme['source_uri']
            )
  end
  
  def self.queued_pending_broadcasts_for(station)
    BroadcastableProgramme.all(:station_id.eql => station.id, :pending_broadcast.eql => true, :order => [:created_at.asc])
  end
  
  def self.broadcasted_programmes_for(station)
    BroadcastableProgramme.all(:station_id.eql => station.id, :pending_broadcast.eql => false, :order => [:updated_at.desc])
  end
  
  def self.number_of_broadcasted_programmes_for(station)
    BroadcastableProgramme.count(:station_id.eql => station.id, :pending_broadcast.eql => false)
  end
  
  def get_tag_id_other_than(tag_id)
    tag_pairs = prog_tags.split(/,/).collect{|tag_pair| tag_pair if !tag_pair.include?(tag_id)}.compact
    tag_pairs.empty? ? nil : tag_pairs[rand(tag_pairs.size)].split('::')[0]
  end
  
  def to_json
    {'audio_uri' => prog_audio_uri, 'title' => prog_title, 'summary' => prog_summary, 'tags' => prog_tags, 
      'published_at' => prog_published_at.to_json, 'source_uri' => prog_source_uri}.to_json
  end
end