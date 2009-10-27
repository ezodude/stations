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
  trial = TrackedListener.has_listener_with_station?(params[:listener_id], params[:keyword])
  p [:trial, trial]
  
  if trial
    station = TrackedListener.get(params[:listener_id]).station_for_keyword(params[:keyword])
    p [:station, station]
    p [:station_to_json, station.to_json]
    
    station.to_json
  else
    status(404)
    @msg = 'Listener not yet tracked or no station matching keyword.'
  end
end

get '/listeners/:listener_id/stations/:station_id.:format' do
  content_type :json
  station = Station.first(:id => params[:station_id], :tracked_listener_id => params[:listener_id])
  if station
    station.to_json
  else
    status(404)
    @msg = 'No station matching this station id.'
  end
end

post '/listeners/:listener_id/stations.:format' do
  begin
    listener = TrackedListener.track_with_station(params[:listener_id], params[:keyword])
    status(201)
    response['Location'] = "#{base_url}listeners/#{listener.id}/stations/#{listener.station_for_keyword(params[:keyword]).id}"
  rescue Exception => e
    puts e
    status(412)
    @msg = 'Could not process this request.'
  end
end

get '/listeners/:listener_id/stations/:station_id/new_programme.:format' do
  content_type :json
  if station = Station.first(:id => params[:station_id], :tracked_listener_id => params[:listener_id])
    begin
      station.seed_station_with_programmes unless station.station_was_started
      new_programme = station.next_programme
      raise RuntimeError.new('Ran out of programmes for this station.') if new_programme.nil?
      new_programme.to_json
    rescue Exception => e
      status(412)
      @msg = e.message
    end
  else
    status(404)
    @msg = 'No station matching this station id.'
  end
end

get '/listeners/:listener_id/stations/:station_id/recent_programmes.:format' do
  content_type :json
  if station = Station.first(:id => params[:station_id], :tracked_listener_id => params[:listener_id])
    begin
      recent_programmes_jsonified = station.recent_programmes.collect {|recent_programme| recent_programme.to_json }
      recent_programmes_jsonified.to_json
    rescue Exception => e
      status(412)
      @msg = e.message
    end
  else
    status(404)
    @msg = 'No station matching this station id.'
  end
end

not_found do
  status(404)
  @msg || "Said.fm doesn't know about that!\n"
end