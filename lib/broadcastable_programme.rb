# encoding: utf-8

class BroadcastableProgramme
  include DataMapper::Resource
  
  property :id, Serial
  property :prog_id, String, :length => 200, :nullable => false
  property :prog_audio_uri, Text, :lazy => false, :nullable => false
  property :prog_title, Text, :lazy => false, :nullable => false
  property :prog_summary, Text
  property :prog_tags, Text, :lazy => false, :nullable => false #tag_id::title,tag_id::title
  property :pending_broadcast, Boolean, :default => true
  timestamps :at
  
  belongs_to :station
  
  def self.build_with(jsonified_programme)
    parsed_programme = JSON.parse(jsonified_programme)
    self.new(:prog_id => parsed_programme['id'], :prog_audio_uri => parsed_programme['audio_uri'], 
              :prog_title => parsed_programme['title'], :prog_summary => parsed_programme['summary'], :prog_tags => parsed_programme['tags'])
  end
  
  def ==(other)
    other.prog_id == prog_id && other.prog_audio_uri == prog_audio_uri \
      && other.prog_title == prog_title && other.prog_summary == prog_summary \
      && other.prog_tags == prog_tags && other.pending_broadcast == pending_broadcast
  end
end