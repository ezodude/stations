# encoding: utf-8

class Podcast
  include DataMapper::Resource
  MIN_MINUTES_DURATION = 9
  
  property :id, String, :length => 200, :key => true, :unique => true
  property :audio_uri, Text, :nullable => false, :unique => true, :lazy => false
  property :title, Text, :nullable => false, :lazy => false
  property :summary, Text, :lazy => false
  property :duration, Integer, :nullable => false
  property :source_uri, Text, :lazy => false, :lazy => false
  property :published_at, Time
  property :file_size, Integer
  property :created_at, Time
  property :updated_at, Time
    
  has n, :classifications
  has n, :tags, :through => :classifications
  
  def self.build_with(audio_uri, title, summary, duration, source_uri, tags, published_at, file_size)
    raise RuntimeError.new("Audio Uri is blank.") if audio_uri.nil? || audio_uri == ""
    raise RuntimeError.new("Incorrect Audio Uri format for [#{audio_uri}], can only accept .mp3 formats.") if File.extname(audio_uri) != ".mp3"
    raise RuntimeError.new("Title is blank.") if title.nil? || title == ""
    
    raise RuntimeError.new("A duration has not been provided.") if duration.nil?
    if duration < MIN_MINUTES_DURATION
      raise RuntimeError.new("A duration has been provided lower than the minimum threshold of #{MIN_MINUTES_DURATION} minutes.")
    end
    
    creation_date = Time.now.utc
    obj = Podcast.new(:id => UUIDTools::UUID.random_create, :audio_uri => audio_uri, :title => title, :summary => summary, 
                  :duration => duration, :source_uri => source_uri, :published_at => published_at.utc, 
                  :file_size => file_size, :created_at => creation_date, :updated_at => creation_date)
    tags.each do |candidate_tag|
      obj.classifications << Classification.build_with(candidate_tag)
    end
    obj
  end

  def ==(other)
    other.id == id && other.audio_uri == audio_uri && other.title == title \
      && other.summary == summary && other.duration == duration && other.source_uri == source_uri \
      && other.published_at == published_at && other.file_size == file_size
  end
  
  def to_json
    flattened_tags = tags.collect{|t| t.to_s}.join(',')
    {'id' => id, 'audio_uri' => audio_uri, 'title' => title, 'summary' => summary, 'tags' => flattened_tags}.to_json
  end
end