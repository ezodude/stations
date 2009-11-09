# encoding: utf-8

require "test/unit"
require 'flexmock/test_unit'

class TrackedListenerTest < Test::Unit::TestCase
  def test_identifies_whether_a_station_for_a_listener_has_already_been_created_for_a_keyword
    mock_listener = flexmock(TrackedListener.new, :id => 'listener-id')
    
    flexmock(TrackedListener).should_receive(:get).with('listener-id').returns(mock_listener)
    flexmock(Station).should_receive(:count) \
      .with(:conditions => ['tracked_listener_id = ? and tracked_keyword = ?', 'listener-id', 'keyword']) \
      .returns(1)
    
    assert(TrackedListener.has_listener_with_station?('listener-id', 'keyword'))
  end
  
  def test_tracks_new_listener_while_adding_new_station_for_keyword
    db_cleanup
    
    flexmock(UUIDTools::UUID, :random_create => 'station-id')
    flexmock(ProgrammesCatalogue, :related_tag_for_keyword => { 'id' => 'tag-id', 'title' => 'title' }.to_json)
    
    testee = TrackedListener.track_with_station('listener-id', 'keyword')
    
    assert_equal(1, testee.stations.size)
    assert_equal('listener-id', testee.stations.first.tracked_listener.id)
    assert_equal('station-id', testee.stations.first.id)
    assert_equal('keyword', testee.stations.first.tracked_keyword)
  end
  
  def test_throws_an_exception_when_there_is_no_available_programme_content_for_keyword
    db_cleanup
    
    flexmock(UUIDTools::UUID, :random_create => 'station-id')
    flexmock(ProgrammesCatalogue, :related_tag_for_keyword => nil)
    
    assert_raise(RuntimeError) { testee = TrackedListener.track_with_station('listener-id', 'keyword')  }
  end
  
  def test_does_not_track_an_already_tracked_listener_but_adds_new_station_for_keyword
    db_cleanup
    
    flexmock(UUIDTools::UUID, :random_create => 'station-id')
    flexmock(ProgrammesCatalogue, :related_tag_for_keyword => { 'id' => 'tag-id', 'title' => 'title' }.to_json)
    
    TrackedListener.create(:id => 'listener-id')
    assert_equal(1, TrackedListener.all.size)
    
    testee = TrackedListener.track_with_station('listener-id', 'keyword')
    
    assert_equal(1, TrackedListener.all.size)
    assert_equal(1, testee.stations.size)
    assert_equal('listener-id', testee.stations.first.tracked_listener.id)
    assert_equal('station-id', testee.stations.first.id)
    assert_equal('keyword', testee.stations.first.tracked_keyword)
  end
  
  def test_throws_an_exception_when_tracked_users_stations_already_exists_for_keyword
    db_cleanup
    
    flexmock(UUIDTools::UUID, :random_create => 'station-id')
    flexmock(ProgrammesCatalogue, :related_tag_for_keyword => { 'id' => 'tag-id', 'title' => 'title' }.to_json)
    
    listener = TrackedListener.create(:id => 'listener-id')
    listener.stations << Station.create(:id => 'listener-id', :tracked_keyword => 'keyword')
    
    assert(listener.save)
    assert_equal(1, TrackedListener.all.size)
    assert_equal(1, Station.all.size)
    
    assert_raise(RuntimeError) { testee = TrackedListener.track_with_station('listener-id', 'keyword')  }
  end
  
  def test_retrieves_station_for_a_keyword
    db_cleanup
    
    flexmock(UUIDTools::UUID, :random_create => 'station-id')
    
    new_station = Station.create(:id => 'listener-id', :tracked_keyword => 'keyword')
    testee = TrackedListener.create(:id => 'listener-id')
    testee.stations << new_station
    
    assert(testee.save)
    assert_equal(new_station, testee.station_for_keyword('keyword'))
  end

private

  def db_cleanup
    Station.all.each { |i| i.destroy }
    TrackedListener.all.each { |i| i.destroy  }
  end
end