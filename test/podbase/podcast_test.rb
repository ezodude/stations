# encoding: utf-8

require "test/unit"
require 'flexmock/test_unit'

class PodcastTest < Test::Unit::TestCase
  FAKE_PODCAST_ID = 'random-podcast-UUID'
  FAKE_TIME = Time.now.utc
  
  AUDIO_URI = "http://download.guardian.co.uk/audio/kip/science/series/science/1246633706179/5438/gdn.sci.ps.090706.apollo.mp3"
  TITLE = "Science Weekly: Apollo 11 special"
  SUMMARY = "&lt;p&gt;In exactly two weeks, Nasa will celebrate&lt;/p&gt;"
  DURATION = 10  #minutes
  SOURCE_URI = "http://www.guardian.co.uk/science/audio/2009/jul/06/apollo-11-moon-landing-astronomy-science-podcast"
  TAGS = ['apollo_11', 'space_exploration', 'science', 'space_technology', 'technology', 'guardian_co_uk', 'alok_jha', 'andy_duckworth']
  PUBLISHED_AT = FAKE_TIME
  # PARSED_PUBLISHED_AT = Time.parse(PUBLISHED_AT).utc
  FILE_SIZE = 36523268
  
  def test_builds_correctly
    setup_mocks
    testee = Podcast.build_with(AUDIO_URI, TITLE, SUMMARY, DURATION, SOURCE_URI, [], PUBLISHED_AT, FILE_SIZE)
    expected = Podcast.new({
      :id => FAKE_PODCAST_ID,
      :audio_uri => AUDIO_URI,
      :title => TITLE,
      :summary => SUMMARY,
      :duration => DURATION,
      :source_uri => SOURCE_URI,
      :published_at => PUBLISHED_AT,
      :file_size => FILE_SIZE,
      :created_at => FAKE_TIME,
      :updated_at =>FAKE_TIME
    })
    assert_equal(expected, testee)
  end
    
  def test_throws_exception_when_created_with_blank_audio_uri
    setup_mocks
    assert_raises(RuntimeError) { Podcast.build_with(nil, TITLE, SUMMARY, DURATION, SOURCE_URI, [], PUBLISHED_AT, FILE_SIZE) }
    assert_raises(RuntimeError) { Podcast.build_with('', TITLE, SUMMARY, DURATION, SOURCE_URI, [], PUBLISHED_AT, FILE_SIZE) }
  end
  
  def test_throws_exception_when_created_for_non_mp3_formatted_audio
    setup_mocks
    invalid_audio_uri = "http://download.guardian.co.uk/audio/kip/science/series/science/1246633706179/5438/gdn.sci.ps.090706.apollo.invalid"
    assert_raises(RuntimeError) do 
      Podcast.build_with(invalid_audio_uri, TITLE, SUMMARY, DURATION, SOURCE_URI, [], PUBLISHED_AT, FILE_SIZE) 
    end
  end
  
  def test_throws_exception_when_created_with_blank_title
    setup_mocks
    assert_raises(RuntimeError) { Podcast.build_with(AUDIO_URI, nil, SUMMARY, DURATION, SOURCE_URI, [], PUBLISHED_AT, FILE_SIZE) }
    assert_raises(RuntimeError) { Podcast.build_with(AUDIO_URI, '', SUMMARY, DURATION, SOURCE_URI, [], PUBLISHED_AT, FILE_SIZE) }
  end
  
  def test_throws_exception_when_created_with_blank_duration
    setup_mocks
    assert_raises(RuntimeError) { Podcast.build_with(AUDIO_URI, TITLE, SUMMARY, nil, SOURCE_URI, [], PUBLISHED_AT, FILE_SIZE) }
    assert_raises(RuntimeError) { Podcast.build_with(AUDIO_URI, TITLE, SUMMARY, 0, SOURCE_URI, [], PUBLISHED_AT, FILE_SIZE) }
  end
  
  def test_throws_exception_when_created_with_duration_less_than_9_minutes
    setup_mocks
    assert_raises(RuntimeError) { Podcast.build_with(AUDIO_URI, TITLE, SUMMARY, 8, SOURCE_URI, [], PUBLISHED_AT, FILE_SIZE) }
  end
  
private
  
  def setup_mocks
    flexmock(UUIDTools::UUID, :random_create => FAKE_PODCAST_ID)
    flexmock(Time, :now => FAKE_TIME)
  end
end