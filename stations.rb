$:.unshift File.join(File.dirname(__FILE__), "config")
$:.unshift File.join(File.dirname(__FILE__), "lib/podbase")

require 'rubygems'
require 'sinatra'

FAKE_LISTENER_ID = '33dcbcd0-902a-012c-8914-0016cbb691d0'
FAKE_STATION_ID = 'station123'

configure do
  require "#{File.dirname(__FILE__)}/config/initialise"
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
      "audio_uri" => "http://cdn.conversationsnetwork.org/ITC.ETech-TimOReilly-2008.03.03.mp3",
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
  if params[:keyword] == 'some-interest'
    fake_station
  else
    status(404)
    @msg = 'No station matching keyword.'
  end
end

get '/listeners/:listener_id/stations/:station_id.:format' do
  if params[:station_id] == FAKE_STATION_ID
    fake_station 
  else
    status(404)
    @msg = 'No station matching this station id.'
  end
end

post '/listeners/:listener_id/stations.:format' do
  if params[:keyword] == 'some-interest'
    status(201)
    response['Location'] = "#{base_url}listeners/#{FAKE_LISTENER_ID}/stations/#{FAKE_STATION_ID}"
  else
    status(412)
    @msg = 'Could not process this request.'
  end
end

get '/listeners/:listener_id/stations/:station_id/new_programme.:format' do
  if params[:station_id] == FAKE_STATION_ID
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