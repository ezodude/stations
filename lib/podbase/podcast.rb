# encoding: utf-8

require 'json'
require 'uuid'
require 'activesupport'

class Podcast
  # include DataMapper::Resource
  MIN_MINUTES_DURATION = 9
  
  # property :id, String, :key => true
  # property :audio_uri, String, :nullable => false
  # property :title, String, :nullable => false
  # property :summary, Text
  # property :duration, Integer
  # property :source_uri, Text
  # property :published_at, DateTime
  # property :file_size, Integer
  # property :created_at, DateTime
  # property :updated_at, DateTime
  # 
  # has n, :classifications
  # has n, :tags, :through => :classifications
  # 
  attr_reader :id, :audio_uri, :title, :summary, :duration, :source_uri, :tags, :published_at
  attr_reader :file_size, :created_at, :updated_at
  
  def self.build(audio_uri, title, summary, duration, source_uri, tags, published_at, file_size)
    raise RuntimeError.new("Audio Uri is blank.") if audio_uri.nil? || audio_uri == ""
    raise RuntimeError.new("Incorrect Audio Uri format for [#{audio_uri}], can only accept .mp3 formats.") if File.extname(audio_uri) != ".mp3"
    
    raise RuntimeError.new("Title is blank.") if title.nil? || title == ""
    
    raise RuntimeError.new("A duration has not been provided.") if duration.nil?
    if duration < MIN_MINUTES_DURATION
      raise RuntimeError.new("A duration has been provided lower than the minimum threshold of #{MIN_MINUTES_DURATION} minutes.")
    end
    
    creation_date = Time.now.utc
    Podcast.new(UUID.generate, audio_uri, title, summary, duration, source_uri, tags, \
                  Time.parse(published_at).utc, file_size, creation_date, creation_date)
  end
  
  def initialize(id, audio_uri, title, summary, duration, source_uri, tags, published_at, file_size, created_at, updated_at)
    @id, @audio_uri, @title = id, audio_uri, title
    @summary, @duration, @source_uri, @tags, @published_at = summary, duration, source_uri, tags, published_at
    @file_size, @created_at, @updated_at = file_size, created_at, updated_at
  end
  
  def ==(other)
    other.id == id && other.audio_uri == audio_uri && other.title == title \
      && other.summary == summary && other.duration == duration && other.source_uri == source_uri && other.tags == tags \
      && other.published_at == published_at && other.file_size == file_size \
      && other.created_at == created_at && other.updated_at == updated_at
  end
  
  def to_json
    {
      :id => id,
      :audio_uri => audio_uri,
      :title => title,
      :summary => summary,
      :duration => duration,
      :source_uri => source_uri,
      :tags => tags,
      :published_at => published_at.to_json,
      :file_size => file_size,
      :created_at => created_at.to_json,
      :updated_at => updated_at.to_json
    }.to_json
  end
end