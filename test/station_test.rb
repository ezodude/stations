# encoding: utf-8

require "test/unit"
require 'flexmock/test_unit'

class StationTest < Test::Unit::TestCase
  def test_is_seeded_with_programmes_matching_keyword_after_initial_creation
    db_cleanup
    setup_mocks('station-id', 'some-id', 'http://www.audio.uri/1.mp3', 'title', 'summary', 'tag-id', 'tag-title')

    testee = Station.create(:tracked_keyword => 'some-keyword', :tracked_listener_id => 'listener_id')
    assert_nil(testee.tag_from_previous_collection)
    
    assert(testee.seed_station_with_programmes)
    assert_equal('tag-id', testee.tag_from_previous_collection)
    assert_equal(BroadcastableProgramme.all(:pending_broadcast.eql => true), testee.programmes_queue)
  end
  
  def test_serves_the_next_pending_programme_from_the_programmes_queue
    db_cleanup
    setup_mocks('station-id', 'some-id', 'http://www.audio.uri/1.mp3', 'title', 'summary', 'tag-id', 'tag-title')
    
    testee = Station.create(:tracked_keyword => 'some-keyword', :tracked_listener_id => 'listener_id')
    testee.seed_station_with_programmes
    next_programme = testee.next_programme
    
    expected_attr_values = ['some-id', 'http://www.audio.uri/1.mp3', 'title', 'summary', "tag-id::tag-title"]
    expected_attr_values.each { |e| assert(next_programme.attributes.values.include?(e)) }
    assert(!next_programme.pending_broadcast)
    assert_equal(0, testee.programmes_queue.size)
  end
  
  def test_is_marked_as_started_on_serving_the_first_pending_programme
    db_cleanup
    setup_mocks('station-id', 'some-id', 'http://www.audio.uri/1.mp3', 'title', 'summary', 'tag-id', 'tag-title')
    
    testee = Station.create(:tracked_keyword => 'some-keyword', :tracked_listener_id => 'listener_id')
    testee.seed_station_with_programmes
    assert(!testee.station_was_started)
    
    testee.next_programme
    assert(testee.station_was_started)
  end
  
  def test_delegates_to_the_tracked_listener_to_ensure_station_is_current_on_serving_the_next_pending_programme
    
  end
  
  def test_seeds_more_programmes_using_random_programme_tag_from_last_5_broadcasted_programmes
    
  end
private

  def db_cleanup
    BroadcastableProgramme.all.each { |i| i.destroy }
    Station.all.each { |i| i.destroy }
    TrackedListener.all.each { |i| i.destroy  }
  end
  
  def setup_mocks(station_id, prog_id, prog_audio_uri, prog_title, prog_summary, tag_id, tag_title)
    flexmock(UUID, :generate => station_id)
    flexmock(ProgrammesCatalogue, :related_tag_for_keyword => { 'id' => tag_id, 'title' => tag_title }.to_json)
    
    tag_programmes = [ 
      {'id' => prog_id, 'audio_uri' => prog_audio_uri, 'title' => prog_title, 'summary' => prog_summary, 'tags' => "#{tag_id}::#{tag_title}"}.to_json
    ].to_json
    
    flexmock(ProgrammesCatalogue).should_receive(:programmes_for_tag).with('tag-id').returns(tag_programmes)
  end
end
