require "test/unit"
require 'flexmock/test_unit'
require 'feed'

class FeedTest < Test::Unit::TestCase
  FAKE_FEED_ID = 'random-feed-UUID'
  FAKE_TIME = Time.now.utc
  
  FEED_URI = 'http://www.guardian.co.uk/science/series/science/rss'
  LAST_BUILD_DATE = FAKE_TIME.rfc822
  PARSED_LAST_BUILD_DATE = Time.parse(LAST_BUILD_DATE).utc
  LANGUAGE = "en"
  DESCRIPTION = 'Articles published by guardian.co.uk Science about: Science + Audio'
  
  def setup
    flexmock(UUID, :generate => FAKE_FEED_ID)
    flexmock(Time, :now => FAKE_TIME)
  end
  
  def test_builds_correctly
    testee = Feed.build(FEED_URI, LAST_BUILD_DATE, LANGUAGE, DESCRIPTION)
    
    expected = Feed.new(FAKE_FEED_ID, FEED_URI, PARSED_LAST_BUILD_DATE, LANGUAGE, DESCRIPTION, FAKE_TIME, FAKE_TIME)
    assert_equal(expected, testee)
  end
  
  def test_throws_exception_when_created_with_blank_feed_uri
    assert_raises(RuntimeError) { Feed.build(nil, LAST_BUILD_DATE, LANGUAGE, DESCRIPTION) }
    assert_raises(RuntimeError) { Feed.build('', LAST_BUILD_DATE, LANGUAGE, DESCRIPTION) }
  end
  
  def test_assigns_english_as_default_language_when_non_is_provided
    assert_equal("en", Feed.build(FEED_URI, LAST_BUILD_DATE, DESCRIPTION).language)
  end
end