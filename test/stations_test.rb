require "test/unit"

require "test/unit"
require 'rack/test'
require 'flexmock/test_unit'
require "stations"

set :environment, :test

class StationsTest < Test::Unit::TestCase
  def test_retrieves_a_listeners_recently_listened_to_programmes_during_active_listening
    browser = setup_mock_browser
    time = Time.now.utc
    
    fake_listener = flexmock(TrackedListener.new, :id => 'some-id')
    fake_station = flexmock('station', :to_json => {'id' => 'some-station-id', 'keyword' => 'some-keyword', 'tracked_listener_id' => fake_listener.id}.to_json)
    fake_prog = flexmock('prog', :to_json => {'audio_uri' => 'http://www.some.uri/1.mp3', 'title' => 'title', 'published_at' => time.to_date.to_json}.to_json)
    recent_progs = [ {'station' => fake_station, 'programmes' => [fake_prog]} ]
    
    fake_listener.should_receive(:recent_programmes_indexed_by_station).returns(recent_progs)
    flexmock(TrackedListener).should_receive(:first).with(:id => 'some-id').returns(fake_listener)
    
    browser.get '/listeners/some-id/recent_programmes.json'
    assert(browser.last_response.ok?)
    
    expected = [ {'station' => fake_station.to_json, 'programmes' => [fake_prog].collect{|prog| prog.to_json}}.to_json ].to_json
    assert_equal(expected, browser.last_response.body)
  end

private

  def setup_mock_browser
    Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
  end
end