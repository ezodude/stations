require 'rubygems'
require 'activesupport'
require 'sinatra'

FAKE_LISTENER_ID = 'random-UUID'

before do 
  # while digesting feeds, strip any html content out?
  # avoid big network feeds and concentrate on seperate channels (not itconversation, but 'tech nation' feed instead)
  # text analyse the channels homepage for high level information for all podcast programmes
  
  # class Station
  #   def keyword; end
  #   def programmes; end
  # end
  
  @stations = [
    {:it_conversations => "http://localhost:3000/sample_programme/test.mp3" },
    {:it => "http://localhost:3000/sample_programme/test.mp3" },
    {:information_technology => "http://localhost:3000/sample_programme/test.mp3" },
    {:technometria => "http://localhost:3000/sample_programme/test.mp3" },
    {:phil_windley => "http://localhost:3000/sample_programme/test.mp3" },
    {:dave_winer => "http://localhost:3000/sample_programme/test.mp3" },
    {:tweeting_the_news => "http://localhost:3000/sample_programme/test.mp3" },
    {:the_internet_and_the_world_wide_web => "http://localhost:3000/sample_programme/test.mp3" },
    {:media => "http://localhost:3000/sample_programme/test.mp3" },
    {:personal_technology => "http://localhost:3000/sample_programme/test.mp3" },
    {:date_20090615 => "http://localhost:3000/sample_programme/test.mp3" },
  ]
  
  # class Programme
  #   def uri; end
  #   def stations; end
  # end
  @podcasts = [
    {"http://localhost:3000/sample_programme/test.mp3" =>  [:it_conversations, :it, :information_technology, :technometria, :phil_windley, :dave_winer, :tweeting_the_news, :the_internet_and_the_world_wide_web, :media, :personal_technology, :date_20090615]},
  ]
  
  # class ListenerSubscriptions
    # def self.load(listener_id); end
    # def initialize(listener_id); end
    # def get_subscription_for(station); end
    # def already_subscribed_to?(station); end
    # def latest_programmes_by_station_for; end
  # end
  
  # class ListenerSubscription
  #   def listener_id_station; end
  #   def listener_id; end
  #   def station; end
  #   def reactivation_date; end # this is updated with the last datetime the subscription was requested by a listener
  #   def requested_programmes; end
  #   def ratings; [programme_uri, :rating]; end
  #   def created_at; end # denotes the date_time the ListenerSubscription was created
  #   def updated_at; end # denotes the date_time of the last new programme request
  # end
  
end

#find stations for a listener and a given (or similar?) interest
#find stations for a listener
#find stations for an interest
get '/listeners/:listener_id/stations.:format' do
  # params[:listener_id]
  # params[:interest]
end

get '/stations/:keyword.:format' do
  
end

post '/stations.:format' do
  #check if interest as station already is available
  
  #check if listener has already registered this (or a similar) interest before
  #Exists: return 400 status explaining 'station already exists'...
  
  #check if listener has already registered this (or a similar) interest before
  #New: create the station for (listener id and interest) and return 201 status with the relevant location...
  headers :Location => "http://#{Sinatra::Application.host}:#{Sinatra::Application.port}/stations/1"
  status 201
end

# get 'listeners/:listener_id/stations/:station_id.:format' do
get '/stations/:id.xml' do
  #check station exists for a listener (using listener id here for very basic security to stop random people identifying someone's interests).
  #NO listener_id: return 400 bad request.
  #Exists: return station including interest data and listener_id
  #Unknown: return status 404 'station is unknown'
  created_at, updated_at = Time.now.utc.rfc822, created_at
  content_type "text/xml"
  expected_station = {
    "id" => 1,
    "interest" => {"id" => 1, "title" => "some-interest", "created_at" => created_at, "updated_at" => updated_at},
    "listener_id" => FAKE_LISTENER_ID,
    "created_at" => created_at,
    "updated_at" => updated_at 
  }.to_xml(:root => "station")
end

# get 'listeners/:listener_id/stations/:station_id/new_programme.:format' do
get '/stations/:id/new_programme.xml' do
  # basic recommendations algorithm - REPETITON IS OKAY.
  
  #check station exists, requires listener_id for very basic security
  #NO: return status 404 'station is unknown'
  
  #Retrieve next podcast from the station queue.
  
  #FOUND: select a programme and return its details in the response.
  #NOT FOUND: return status 404 'No available programming for station' the programme details in the response.
  
  content_type "text/xml"
  expected_programme = {
    "title" => "Tweeting the News",
    "location" => "http://localhost:3000/sample_programme/test.mp3",
    "duration" => 2580000, # in milliseconds
    "info" => "http://itc.conversationsnetwork.org/shows/detail4147.html",
    "creator" => "Technometria with Phil Windley",
    "interviewee" => "Dave Winer",
  }.to_xml(:root => "programme")
end