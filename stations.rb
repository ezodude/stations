$:.unshift File.join(File.dirname(__FILE__), "config")
$:.unshift File.join(File.dirname(__FILE__), "lib/podbase")

require 'rubygems'
require 'sinatra'

configure do
  require "#{File.dirname(__FILE__)}/config/initialise"
end

helpers do
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
  
  if trial
    station = TrackedListener.get(params[:listener_id]).station_for_keyword(params[:keyword])
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
    status(412)
    @msg = "Could not process this request. Exception [#{e.message}]"
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
      @msg = "Could not process this request. Exception [#{e.message}]"
    end
  else
    status(404)
    @msg = 'No station matching this station id.'
  end
end

get '/listeners/:listener_id/recent_programmes.:format' do
  content_type :json
  if listener = TrackedListener.first(:id => params[:listener_id])
    begin
      recent_progs = params[:listening_state] == 'inactive' ? \
          listener.recent_programmes_indexed_by_station(active_listening=false) : listener.recent_programmes_indexed_by_station
      recent_programmes_jsonified = recent_progs.collect do |recent_programme| 
        { 'station' => recent_programme['station'].to_json, 'programmes' => recent_programme['programmes'].collect{|prog|prog.to_json} }.to_json
      end
      recent_programmes_jsonified.to_json
    rescue Exception => e
      status(412)
      @msg = "#{e.backtrace} - #{e.message}"
    end
  else
    status(404)
    @msg = 'No listener matching this station id.'
  end
end

not_found do
  status(404)
  @msg || "Said.fm doesn't know about that!\n"
end