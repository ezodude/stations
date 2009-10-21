require "test/unit"
require 'flexmock/test_unit'
require 'builder'
require 'podcast_collector'
require 'podcast'

class PodcastCollectorTest < Test::Unit::TestCase
  FAKE_PODCAST_ID = 'random-podcast-UUID'
  FAKE_TIME = Time.now.utc
  
  FEED_URI = 'http://rss.conversationsnetwork.org/series/technation.xml'
  PODCAST_PUBLISHED_DATE = 'Thu, 1 Oct 2009 00:00:00 CDT'
  
  def setup
    flexmock(UUID, :generate => FAKE_PODCAST_ID)
    flexmock(Time, :now => FAKE_TIME)
  end
  
  def test_collects_podcasts_with_a_valid_duration_field
    builder = Builder::XmlMarkup.new
    builder.instruct! :xml, :version => "1.0"
    expected_feed_xml = builder.rss('version' => '2.0') { |feed|
      feed.channel {|channel|
        channel.title('Tech Nation')
        channel.link('http://itc.conversationsnetwork.org/series/technation.html')
        channel.item { |channel_item|
          channel_item.title('Gordon Bell, Jim Gemmell - Total Recall')
          channel_item.link('http://itc.conversationsnetwork.org/shows/detail4249.html')
          channel_item.description(%Q(Moira talks with Gorden Bell and Jim Gemmell about what it means to digitally record everything in our lives. The authors of Total Recall: How the E-Memory Revolution Will Change Everything discuss how new technologies allow average people to record their entire lives.))
          channel_item.pubDate('Thu, 1 Oct 2009 00:00:00 CDT')
          channel_item.guid({'isPermaLink' => 'false'}, 'http://www.conversationsnetwork.org/episode-4249')
          channel_item.enclosure({'url' => 'http://cdn.conversationsnetwork.org/ITC.TN-BellGemmell-2009.09.22.mp3', 'length' => '15286592', 'type' => 'audio/mpeg'})
        }
      }
    }
    flexmock(Feedzirra::Feed, :decode_content => expected_feed_xml)
    testee = PodcastCollector.new([FEED_URI])
    testee.collect_podcasts
    assert_equal([], testee.collected_podcasts)
  end

  def test_collects_podcasts_from_itunes_tagged_rss_feeds
      builder = Builder::XmlMarkup.new
      builder.instruct! :xml, :version => "1.0"
      expected_feed_xml = builder.rss('version' => '2.0', 'xmlns:itunes' => 'http://www.itunes.com/dtds/podcast-1.0.dtd' ) { |feed|
        feed.channel {|channel|
          channel.title('Tech Nation')
          channel.itunes(:author, 'The Conversations Network')
          channel.itunes(:explicit, 'no')
          channel.itunes(:keywords, 'it,information technology,technation,science,technology')
          channel.itunes(:owner) { |owner|
            owner.itunes(:name, 'The Conversations Network')
            owner.email(:name, 'The webmaster@conversationsnetwork.org (The Conversations Network)')
          }
          channel.link('http://itc.conversationsnetwork.org/series/technation.html')
          channel.image { |channel_image| 
            channel_image.url('http://assets.conversationsnetwork.org/channels/ITConversations/itc-300x300.jpg')
            channel_image.title('Tech Nation')
            channel_image.link('http://itc.conversationsnetwork.org/series/technation.html')
          }
          channel.item { |channel_item|
            channel_item.title('Gordon Bell, Jim Gemmell - Total Recall')
            channel_item.link('http://itc.conversationsnetwork.org/shows/detail4249.html')
            channel_item.description(%Q(Moira talks with Gorden Bell and Jim Gemmell about what it means to digitally record everything in our lives. The authors of Total Recall: How the E-Memory Revolution Will Change Everything discuss how new technologies allow average people to record their entire lives.))
            channel_item.pubDate('Thu, 1 Oct 2009 00:00:00 CDT')
            channel_item.guid({'isPermaLink' => 'false'}, 'http://www.conversationsnetwork.org/episode-4249')
            channel_item.enclosure({'url' => 'http://cdn.conversationsnetwork.org/ITC.TN-BellGemmell-2009.09.22.mp3', 'length' => '15286592', 'type' => 'audio/mpeg'})
            channel_item.itunes(:keywords, 'personalTechnology,privacy')
            channel_item.itunes(:duration, '00:31:51')
          }
        }
      }
      flexmock(Feedzirra::Feed, :decode_content => expected_feed_xml)
      expected_tags = ['it','information_technology', 'technation', 'science', 'technology', 'personal_technology','privacy']
      expected_duration = 31
      expected_podcast = Podcast.build('http://cdn.conversationsnetwork.org/ITC.TN-BellGemmell-2009.09.22.mp3', 'Gordon Bell, Jim Gemmell - Total Recall', [], %Q(Moira talks with Gorden Bell and Jim Gemmell about what it means to digitally record everything in our lives. The authors of Total Recall: How the E-Memory Revolution Will Change Everything discuss how new technologies allow average people to record their entire lives.), expected_duration, 'http://itc.conversationsnetwork.org/shows/detail4249.html', expected_tags, PODCAST_PUBLISHED_DATE, 15286592)
      
      testee = PodcastCollector.new([FEED_URI])
      testee.collect_podcasts
      assert_equal([expected_podcast], testee.collected_podcasts)
    end
  
  def test_collects_podcasts_from_media_tagged_rss_feeds
    
  end
  
  def test_collects_podcasts_from_dublin_core_tagged_rss_feeds
    
  end
end