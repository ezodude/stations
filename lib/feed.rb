require 'json'
require 'uuid'
require 'active_support'

class Feed
  attr_reader :id, :feed_uri, :last_build_date, :language, :description, :created_at, :updated_at
  def self.build(feed_uri, last_build_date, language="en", description)
    raise RuntimeError.new("Feed Uri is blank.") if feed_uri.nil? || feed_uri == ""
    creation_date = Time.now.utc
    Feed.new(UUID.generate, feed_uri, Time.parse(last_build_date).utc, language, description, creation_date, creation_date)
  end
  
  def initialize(id, feed_uri, last_build_date, language, description, created_at, updated_at)
    @id, @feed_uri, @last_build_date, @language = id, feed_uri, last_build_date, language
    @description, @created_at, @updated_at = description, created_at, updated_at
  end
  
  def ==(other)
    other.id == id && other.feed_uri == feed_uri && other.last_build_date == last_build_date \
    && other.language == language && other.description == description \
    && other.created_at == created_at && other.updated_at == updated_at
  end
end