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
    
    listener = TrackedListener.create(:id => 'listener_id')
    testee = Station.create(:tracked_keyword => 'some-keyword', :tracked_listener => listener)
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
    
    listener = TrackedListener.create(:id => 'listener_id')
    testee = Station.create(:tracked_keyword => 'some-keyword', :tracked_listener => listener)
    testee.seed_station_with_programmes
    assert(!testee.station_was_started)
    
    testee.next_programme
    assert(testee.station_was_started)
  end
  
  def test_delegates_to_the_tracked_listener_to_ensure_station_is_current_on_serving_the_next_pending_programme
    db_cleanup
    setup_mocks('station-id', 'some-id', 'http://www.audio.uri/1.mp3', 'title', 'summary', 'tag-id', 'tag-title')
    listener = TrackedListener.create(:id => 'listener_id')
    testee = Station.create(:tracked_keyword => 'some-keyword', :tracked_listener => listener)
    
    testee.seed_station_with_programmes
    assert(!testee.is_current_station)
    
    testee.next_programme
    assert(testee.is_current_station)
  end
  
  def test_seeds_more_programmes_using_random_programme_tag_from_last_5_broadcasted_programmes
    db_cleanup
    flexmock(UUID, :generate => 'station-id')
    flexmock(ProgrammesCatalogue).should_receive(:related_tag_for_keyword) \
      .returns( \
        { 'id' => 'tag1-id', 'title' => 'tag1-title' }.to_json, \
        { 'id' => 'tag2-id', 'title' => 'tag2-title' }.to_json, \
    )
    
    tag1_programmes = [ 
      {'id' => 'id1', 'audio_uri' => 'http://www.audio.uri/1.mp3', 'title' => 'title2', 'summary' => 'summary1', 'tags' => "tag1-id::tag1-title,tag2-id::tag2-title"}.to_json
    ].to_json
    
    tag2_programmes = [ 
      {'id' => 'id2', 'audio_uri' => 'http://www.audio.uri/2.mp3', 'title' => 'title2', 'summary' => 'summary2', 'tags' => "tag2-id::tag2-title,tag3-id::tag3-title"}.to_json
    ].to_json
    
    # flexmock(ProgrammesCatalogue).should_receive(:programmes_for_tag).with(tag_id).returns(tag_programmes)
    flexmock(ProgrammesCatalogue).should_receive(:programmes_for_tag).returns(tag1_programmes, tag2_programmes)
    
    flexmock(Kernel).should_receive(:rand).with(5).returns(0)
    
    listener = TrackedListener.create(:id => 'listener_id')
    testee = Station.create(:tracked_keyword => 'some-keyword', :tracked_listener => listener)
    testee.seed_station_with_programmes
    
    testee.next_programme
    assert_equal(0, testee.programmes_queue.size)
    
    newly_seeded_programme = testee.next_programme
    expected_attr_values = ['id2', 'http://www.audio.uri/2.mp3', 'title2', 'summary2', "tag2-id::tag2-title,tag3-id::tag3-title"]
    expected_attr_values.each { |e| assert(newly_seeded_programme.attributes.values.include?(e)) }
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
    
    flexmock(ProgrammesCatalogue).should_receive(:programmes_for_tag).with(tag_id).returns(tag_programmes)
  end
end
