require "test/unit"
require 'flexmock/test_unit'
require 'podcast'

class PodcastTest < Test::Unit::TestCase
  FAKE_PODCAST_ID = 'random-podcast-UUID'
  FAKE_TIME = Time.now.utc
  
  AUDIO_URI = "http://download.guardian.co.uk/audio/kip/science/series/science/1246633706179/5438/gdn.sci.ps.090706.apollo.mp3"
  TITLE = "Science Weekly: Apollo 11 special"
  PARTICIPANTS = ['Alok Jha', 'Andy Duckworth']
  SUMMARY = "&lt;p&gt;In exactly two weeks, Nasa will celebrate&lt;/p&gt;"
  DURATION = 10  #minutes
  SOURCE_URI = "http://www.guardian.co.uk/science/audio/2009/jul/06/apollo-11-moon-landing-astronomy-science-podcast"
  TAGS = ['apollo_11', 'space_exploration', 'science', 'space_technology', 'technology', 'guardian.co.uk', 'editorial']
  PUBLISHED_AT = FAKE_TIME.rfc822 # extracted from format based on http://asg.web.cmu.edu/rfc/rfc822.html
  PARSED_PUBLISHED_AT = Time.parse(PUBLISHED_AT).utc
  FILE_SIZE = 36523268
  
  def setup
    flexmock(UUID, :generate => FAKE_PODCAST_ID)
    flexmock(Time, :now => FAKE_TIME)
  end
  
  def test_builds_correctly
    testee = Podcast.build(AUDIO_URI, TITLE, PARTICIPANTS, SUMMARY, DURATION, SOURCE_URI, TAGS, PUBLISHED_AT, FILE_SIZE)
    
    expected = Podcast.new(FAKE_PODCAST_ID, AUDIO_URI, TITLE, PARTICIPANTS, SUMMARY, DURATION, SOURCE_URI, TAGS, \
                            PARSED_PUBLISHED_AT, FILE_SIZE, FAKE_TIME, FAKE_TIME)
    
    assert_equal(expected, testee)
  end
  
  def test_translates_itself_into_json
    testee = Podcast.build(AUDIO_URI, TITLE, PARTICIPANTS, SUMMARY, DURATION, SOURCE_URI, TAGS, PUBLISHED_AT, FILE_SIZE)
    expected = {
      :id => FAKE_PODCAST_ID,
      :audio_uri => AUDIO_URI,
      :title => TITLE,
      :participants => PARTICIPANTS,
      :summary => SUMMARY,
      :duration => DURATION,
      :source_uri => SOURCE_URI,
      :tags => TAGS,
      :published_at => PARSED_PUBLISHED_AT.to_json,
      :file_size => FILE_SIZE,
      :created_at => FAKE_TIME.to_json,
      :updated_at => FAKE_TIME.to_json
    }.to_json
    assert_equal(expected, testee.to_json)
  end
  
  def test_throws_exception_when_created_with_blank_audio_uri
    assert_raises(RuntimeError) { Podcast.build(nil, TITLE, PARTICIPANTS, SUMMARY, DURATION, SOURCE_URI, TAGS, PUBLISHED_AT, FILE_SIZE) }
    assert_raises(RuntimeError) { Podcast.build('', TITLE, PARTICIPANTS, SUMMARY, DURATION, SOURCE_URI, TAGS, PUBLISHED_AT, FILE_SIZE) }
  end
  
  def test_throws_exception_when_created_for_non_mp3_formatted_audio
    invalid_audio_uri = "http://download.guardian.co.uk/audio/kip/science/series/science/1246633706179/5438/gdn.sci.ps.090706.apollo.invalid"
    assert_raises(RuntimeError) do 
      Podcast.build(invalid_audio_uri, TITLE, PARTICIPANTS, SUMMARY, DURATION, SOURCE_URI, TAGS, PUBLISHED_AT, FILE_SIZE) 
    end
  end
  
  def test_throws_exception_when_created_with_blank_title
    assert_raises(RuntimeError) { Podcast.build(AUDIO_URI, nil, PARTICIPANTS, SUMMARY, DURATION, SOURCE_URI, TAGS, PUBLISHED_AT, FILE_SIZE) }
    assert_raises(RuntimeError) { Podcast.build(AUDIO_URI, '', PARTICIPANTS, SUMMARY, DURATION, SOURCE_URI, TAGS, PUBLISHED_AT, FILE_SIZE) }
  end
  
  def test_throws_exception_when_created_with_blank_duration
    assert_raises(RuntimeError) { Podcast.build(AUDIO_URI, TITLE, PARTICIPANTS, SUMMARY, nil, SOURCE_URI, TAGS, PUBLISHED_AT, FILE_SIZE) }
    assert_raises(RuntimeError) { Podcast.build(AUDIO_URI, TITLE, PARTICIPANTS, SUMMARY, 0, SOURCE_URI, TAGS, PUBLISHED_AT, FILE_SIZE) }
  end
  
  def test_throws_exception_when_created_with_duration_less_than_9_minutes
    assert_raises(RuntimeError) { Podcast.build(AUDIO_URI, TITLE, PARTICIPANTS, SUMMARY, 8, SOURCE_URI, TAGS, PUBLISHED_AT, FILE_SIZE) }
  end
end