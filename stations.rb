$:.unshift File.join(File.dirname(__FILE__), "config")
$:.unshift File.join(File.dirname(__FILE__), "lib/podbase")

require 'rubygems'
require 'sinatra'

FAKE_LISTENER_ID = '33dcbcd0-902a-012c-8914-0016cbb691d0'
FAKE_STATION_ID = 'station123'

configure do
  require "#{File.dirname(__FILE__)}/config/initialise"
end

before do
  # class ThemeMapping
  #   def self.load(theme_mappings_data='theme_mappings.json'); end
  #   def self.theme_mapping_for(keyword); end
  #   def theme; end
  #   def programmes; end
  #   def to_json; end
  # end
  
  @theme_mappings = [
    {:it_conversations => ["http://localhost:3000/sample_programme/test.mp3"] },
    {:it => ["http://localhost:3000/sample_programme/test.mp3"] },
    {:information_technology => ["http://localhost:3000/sample_programme/test.mp3"] },
    {:technometria => ["http://localhost:3000/sample_programme/test.mp3"] },
    {:phil_windley => ["http://localhost:3000/sample_programme/test.mp3"] },
    {:dave_winer => ["http://localhost:3000/sample_programme/test.mp3"] },
    {:tweeting_the_news => ["http://localhost:3000/sample_programme/test.mp3"] },
    {:the_internet_and_the_world_wide_web => ["http://localhost:3000/sample_programme/test.mp3"] },
    {:media => ["http://localhost:3000/sample_programme/test.mp3"] },
    {:personal_technology => ["http://localhost:3000/sample_programme/test.mp3"] },
    {:date_20090615 => ["http://localhost:3000/sample_programme/test.mp3"] },
  ]
  
  # class Programme #(Podcast??)
  #   def self.load(programmes_data='programmes.json'); end
  #   def self.programme_for(uri); end
  #   def uri; end
  #   def title; end
  #   def themes; end
  #   def to_json; end
  # end
  # @programmes = [ 
  #   #programme
  #   {"http://localhost:3000/sample_programme/test.mp3" =>  
  #     [:it_conversations, :it, :information_technology, :technometria, :phil_windley, :dave_winer, 
  #       :tweeting_the_news, :the_internet_and_the_world_wide_web, :media, :personal_technology, :date_20090615]
  #   },
  # ]
    
  # class Listener
  #   def self.load(listener_stations_data="listener_stations.json");end
  #   def self.create_station_for(listener_id, keyword); end
  #   def initialize(listener_id, keyword); end
  #   def listener_id;end
  #   def stations; end
  #   def recent_stations; end
  #   def station_for(keyword); end
  #   def has_station_for?(keyword);end
  #   def to_json;end
  #   def to_xml;end
  # end
  # class Station
  #   def id; end #UUID
  #   def keyword; end
  #   def seed_station_with_programmes; end
  #   def programmes_queue; end
  #   def sent_programmes; end # [{:date_requested => date_time, :uri => uri, :theme_id => station_id}]
  #   def feedback_for(uri, rating); end
  #   def reactivation_date; end # this is updated with the last datetime the subscription was requested by a listener
  #   def next_programme; end
  #   def created_at; end
  #   def to_json;end
  #   def to_xml;end
  # end
  
  # @listener_stations = [Listener.create_station_for(FAKE_LISTENER_ID, "media")]
end

helpers do
  def fake_station
    created_at = Time.now.utc.rfc822
    {
      "id" => FAKE_STATION_ID,
      "keyword" => "some-interest",
      "listener_id" => FAKE_LISTENER_ID,
      "created_at" => created_at
    }.to_json
  end
  
  def fake_programme
    {
      "title" => "The Story",
      "audio_uri" => "http://localhost:3000/sample_programme/test.mp3",
      "themes" => "theme1,theme2,theme3"
    }.to_json
  end
  
  def base_url
    if Sinatra::Application.port == 80
      "http://#{Sinatra::Application.host}/"
    else
      "http://#{Sinatra::Application.host}:#{Sinatra::Application.port}/"
    end
  end
end

get '/listeners/:listener_id/station.:format' do
  content_type :json
  if params[:listener_id] == FAKE_LISTENER_ID && params[:keyword] == 'some-interest'
    fake_station
  else
    status(404)
    @msg = 'No station matching keyword.'
  end
end

get '/listeners/:listener_id/stations/:station_id.:format' do
  if params[:listener_id] == FAKE_LISTENER_ID && params[:station_id] == FAKE_STATION_ID
    fake_station 
  else
    status(404)
    @msg = 'No station matching this station id.'
  end
end

post '/listeners/:listener_id/stations.:format' do
  if params[:listener_id] == FAKE_LISTENER_ID && params[:keyword] == 'some-interest'
    status(201)
    response['Location'] = "#{base_url}listeners/#{FAKE_LISTENER_ID}/stations/#{FAKE_STATION_ID}"
  else
    status(412)
    @msg = 'Could not process this request.'
  end
end

get '/listeners/:listener_id/stations/:station_id/new_programme.:format' do
  if params[:listener_id] == FAKE_LISTENER_ID && params[:station_id] == FAKE_STATION_ID
    fake_programme
  else
    status(404)
    @msg = 'No station matching this station id.'
  end
end

not_found do
  status(404)
  @msg || "Said.fm doesn't know about that!\n"
end