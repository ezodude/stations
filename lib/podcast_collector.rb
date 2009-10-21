# encoding: utf-8

require 'feedzirra'
require 'activesupport'

module SaidFm
  class PodcastRSSEntry
    include SAXMachine
    include Feedzirra::FeedEntryUtilities
    element :title
    element :link, :as => :url

    element :"dc:creator", :as => :author
    element :author, :as => :author
    element :"content:encoded", :as => :content
    element :description, :as => :summary

    element :pubDate, :as => :published
    element :pubdate, :as => :published
    element :"dcterms:created", :as => :published

    element :"dcterms:modified", :as => :updated
    element :issued, :as => :published
    
    elements :category, :as => :categories
    element :"itunes:keywords", :as => :itunes_keywords
    
    element :guid, :as => :id
    
    element :enclosure, :value => :url, :as => :audio_uri, :with => {:type => "audio/mpeg"}
    element :"itunes:duration", :as => :itunes_duration
    element :enclosure, :value => :length, :as => :audio_size, :with => {:type => "audio/mpeg"}
    
    element :"media:content", :value => :url, :as => :audio_uri, :with => {:type => "audio/mpeg"}
    element :"media:content", :value => :duration, :as => :media_duration, :with => {:type => "audio/mpeg"}
    element :"media:content", :value => :fileSize, :as => :audio_size, :with => {:type => "audio/mpeg"}
  end
  class PodcastRSS
    include SAXMachine
    include Feedzirra::FeedUtilities
    element :"itunes:keywords", :as => :itunes_keywords
    elements :item, :as => :entries, :class => SaidFm::PodcastRSSEntry
    attr_accessor :feed_url
    def self.able_to_parse?(xml)
      xml =~ /\<rss/
    end
  end
end

Feedzirra::Feed.add_feed_class(SaidFm::PodcastRSS)

class PodcastCollector
  SECONDS_IN_MINUTE = 60
  attr_reader :collected_podcasts
  
  def initialize(feed_uris=[])
    @feed_uris = feed_uris
    @collected_podcasts = []
  end
  
  def collect_podcasts
    @feed_uris.each do |uri|
      feed = Feedzirra::Feed.fetch_and_parse(uri)

      feed_keywords = grab_any_feed_tags(feed)
  	  @collected_podcasts = feed.entries.inject([]) do |collection, entry|
  	    participants = tagify(entry.author.nil? ? [] : entry.author.split(/,/))
  	    tags = tagify(feed_keywords + grab_any_entry_tags(entry) + participants).uniq
  	    duration_in_minutes = determine_duration_from(entry)
  	    
  	    if duration_in_minutes >= Podcast::MIN_MINUTES_DURATION
    	    collection << Podcast.build(entry.audio_uri, entry.title, participants, entry.summary.strip, duration_in_minutes, entry.url, \
    	                      tags, entry.published, entry.audio_size.to_i)
    	  end
    	  collection
  	  end
    end
  end

private
  
  def grab_any_feed_tags(feed)
    keywords = []
    keywords = feed.itunes_keywords.split(/,/).flatten unless feed.itunes_keywords.nil?
    keywords.collect {|keyword| keyword.underscore}
  end
  
  def grab_any_entry_tags(entry)
    keywords = []
    keywords = entry.categories.split(/,/).flatten unless entry.categories.nil?
    keywords = entry.itunes_keywords.split(/,/).flatten unless entry.itunes_keywords.nil?
    keywords.collect {|keyword| keyword.underscore }
  end
    
  def tagify(values=[])
    values.collect do |value|
      value.gsub!('.', '_')
      if value.include?(' ')
        value.split(' ').collect{|w| w.capitalize}.join.underscore
      else
        value.underscore
      end
    end
  end
  
  def determine_duration_from(entry)
    return Time.parse(entry.itunes_duration).min unless entry.itunes_duration.nil?
    return (entry.media_duration.to_i / SECONDS_IN_MINUTE) unless entry.media_duration.nil?
    return 0
  end
end