# encoding: utf-8

module SaidFm
  class PodcastRSSEntry
    include SAXMachine
    include Feedzirra::FeedEntryUtilities
    element :title
    element :link, :as => :url

    element :"dc:creator", :as => :author
    element :author, :as => :author
    element :description, :as => :summary

    element :pubDate, :as => :published
    element :pubdate, :as => :published
    element :"dcterms:created", :as => :published

    element :"dcterms:modified", :as => :updated
    element :issued, :as => :published
    
    elements :category, :as => :categories
    elements :"dc:subject", :as => :categories
    element :"itunes:keywords", :as => :itunes_keywords
    
    element :guid, :as => :id
    
    element :enclosure, :value => :url, :as => :audio_uri, :with => {:type => "audio/mpeg"}
    element :enclosure, :value => :url, :as => :audio_uri, :with => {:type => "audio/mp3"}
    element :"itunes:duration", :as => :itunes_duration
    element :enclosure, :value => :length, :as => :audio_size, :with => {:type => "audio/mpeg"}
    element :enclosure, :value => :length, :as => :audio_size, :with => {:type => "audio/mp3"}
    
    
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
      xml =~ /\<rss|\<rdf/
    end
  end
end

Feedzirra::Feed.add_feed_class(SaidFm::PodcastRSS)

class PodcastCollector
  include SaidFm::PodcastDataExtractorUtils
  
  attr_reader :collected_podcasts
  
  def initialize(feed_uris=[])
    @feed_uris = feed_uris
    @collected_podcasts = {}
  end
  
  def collect_podcasts
    @feed_uris.each do |feed_uri|
      @collected_podcasts[feed_uri] = []
      
      feed = Feedzirra::Feed.fetch_and_parse(feed_uri)
      feed_keywords = collect_any_keywords_from(feed)
      
      candidates = feed.entries.delete_if{ |entry| entry.audio_uri.nil? }
  	  @collected_podcasts[feed_uri] += candidates.inject([]) do |collection, entry|
  	    participants = tagify(entry.author.nil? ? [] : entry.author.split(/,/))
  	    tags = tagify(feed_keywords + collect_any_keywords_from(entry) + participants).uniq
  	    duration_in_minutes = determine_duration_from(entry)
  	    
  	    if duration_in_minutes >= Podcast::MIN_MINUTES_DURATION
  	      begin
  	        if Podcast.first(:audio_uri => entry.audio_uri).nil?
  	          published_at = entry.published.respond_to?(:utc) ? entry.published.utc : Time.parse(entry.published).utc
    	        podcast = Podcast.build_with(entry.audio_uri, entry.title, entry.summary.strip, duration_in_minutes, entry.url, \
        	                      tags, published_at, entry.audio_size.to_i)
              raise RuntimeError.new("Could not save collected podcast,errors #{podcast.errors.inspect}") unless podcast.save
      	    
        	    collection << podcast
        	  end
      	  rescue RuntimeError => e
      	    puts "Feed url: [#{feed.feed_url}], podcast audio uri: [#{entry.audio_uri}] \nException: [#{e.message}]"
    	    end
    	  end
    	  collection
  	  end
    end
  end
end