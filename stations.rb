require 'rubygems'
require 'activesupport'
require 'sinatra'

FAKE_LISTENER_ID = 'random-UUID'

post '/stations.xml' do
  headers :Location => "http://#{Sinatra::Application.host}:#{Sinatra::Application.port}/stations/1"
  status 201
end

get '/stations/1.xml' do
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

get '/stations/1/new_programme.xml' do
  content_type "text/xml"
  expected_programme = {
    "title" => "Tweeting the News",
    "location" => "http://localhost:3000/sample_programme/dave_winer_tweeting_the_news.mp3",
    "duration" => 2580000, # in milliseconds
    "info" => "http://itc.conversationsnetwork.org/shows/detail4147.html",
    "creator" => "Technometria with Phil Windley",
    "interviewee" => "Dave Winer",
  }.to_xml(:root => "programme")
end
