# encoding: utf-8
$:.unshift File.join(File.dirname(__FILE__), "../..", "lib/podbase")

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
  
  def test_does_not_collect_podcasts_with_a_missing_duration_field
    ['audio/mpeg', 'audio/mp3'].each do |enclosure_format_type|
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
  end

  def test_collects_podcasts_from_itunes_tagged_rss_feeds
    ['audio/mpeg', 'audio/mp3'].each do |enclosure_format_type|
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
          channel.item { |channel_item|
            channel_item.title('Gordon Bell, Jim Gemmell - Total Recall')
            channel_item.link('http://itc.conversationsnetwork.org/shows/detail4249.html')
            channel_item.description(%Q(Moira talks with Gorden Bell and Jim Gemmell about what it means to digitally record everything in our lives. The authors of Total Recall: How the E-Memory Revolution Will Change Everything discuss how new technologies allow average people to record their entire lives.))
            channel_item.pubDate('Thu, 1 Oct 2009 00:00:00 CDT')
            channel_item.guid({'isPermaLink' => 'false'}, 'http://www.conversationsnetwork.org/episode-4249')
            channel_item.enclosure({'url' => 'http://cdn.conversationsnetwork.org/ITC.TN-BellGemmell-2009.09.22.mp3', 'length' => '15286592', 
                                    'type' => enclosure_format_type})
            channel_item.itunes(:keywords, 'personalTechnology,privacy')
            channel_item.itunes(:duration, '00:31:51')
          }
        }
      }
      flexmock(Feedzirra::Feed, :decode_content => expected_feed_xml)
      expected_tags = ['it','information_technology', 'technation', 'science', 'technology', 'personal_technology','privacy']
      expected_duration = 31
      expected_podcast = Podcast.build('http://cdn.conversationsnetwork.org/ITC.TN-BellGemmell-2009.09.22.mp3', 'Gordon Bell, Jim Gemmell - Total Recall', %Q(Moira talks with Gorden Bell and Jim Gemmell about what it means to digitally record everything in our lives. The authors of Total Recall: How the E-Memory Revolution Will Change Everything discuss how new technologies allow average people to record their entire lives.), expected_duration, 'http://itc.conversationsnetwork.org/shows/detail4249.html', expected_tags, PODCAST_PUBLISHED_DATE, 15286592)

      testee = PodcastCollector.new([FEED_URI])
      testee.collect_podcasts
      assert_equal([expected_podcast], testee.collected_podcasts)
    end
  end
  
  def test_does_not_collect_podcasts_with_a_missing_audio_uri_field
    builder = Builder::XmlMarkup.new
    builder.instruct! :xml, :version => "1.0"
    expected_feed_xml = builder.rss('version' => '2.0', 'xmlns:itunes' => 'http://www.itunes.com/dtds/podcast-1.0.dtd' ) { |feed|
      feed.channel {|channel|
        channel.title('Tech Nation')
        channel.link('http://itc.conversationsnetwork.org/series/technation.html')
        channel.item { |channel_item|
          channel_item.title('Gordon Bell, Jim Gemmell - Total Recall')
          channel_item.link('http://itc.conversationsnetwork.org/shows/detail4249.html')
          channel_item.description(%Q(Moira talks with Gorden Bell and Jim Gemmell about what it means to digitally record everything in our lives. The authors of Total Recall: How the E-Memory Revolution Will Change Everything discuss how new technologies allow average people to record their entire lives.))
          channel_item.pubDate('Thu, 1 Oct 2009 00:00:00 CDT')
          channel_item.guid({'isPermaLink' => 'false'}, 'http://www.conversationsnetwork.org/episode-4249')
          # channel_item.enclosure({'url' => 'http://cdn.conversationsnetwork.org/ITC.TN-BellGemmell-2009.09.22.mp3', 'length' => '15286592', 'type' => 'audio/mpeg'})
          channel_item.itunes(:keywords, 'personalTechnology,privacy')
          channel_item.itunes(:duration, '00:31:51')
        }
      }
    }
    flexmock(Feedzirra::Feed, :decode_content => expected_feed_xml)
    testee = PodcastCollector.new([FEED_URI])
    testee.collect_podcasts
    assert_equal([], testee.collected_podcasts)
  end
  
  def test_collects_podcasts_from_media_tagged_rss_feeds
    ['audio/mpeg', 'audio/mp3'].each do |enclosure_format_type|
      builder = Builder::XmlMarkup.new
      builder.instruct! :xml, :version => "1.0"
      expected_feed_xml = builder.rss('version' => '2.0', 'xmlns:media' => 'http://search.yahoo.com/mrss/') { |feed| 
        feed.channel {|channel|
          channel.title('Science: Science + Audio | guardian.co.uk')
          channel.link('http://www.guardian.co.uk/science/science+content/audio')
          channel.item { |channel_item|
            channel_item.title(%Q(Science Weekly podcast: Backing up the Earth's biodiversity))
            channel_item.link('http://www.guardian.co.uk/science/audio/2009/aug/10/science-weekly-podcast-seeds-biodiversity')
            channel_item.description(%Q(&lt;p&gt;&lt;strong&gt;Cary Fowler&lt;/strong&gt; from the &lt;a href="http://www.croptrust.org/main/"&gt;Global Crop Diversity Trust&lt;/a&gt; discusses his plans to develop a global system for &lt;a href="http://www.guardian.co.uk/media/pda/2009/jul/22/climate-change-agriculture"&gt;conserving the biodiversity of all agricultural crops&lt;/a&gt;, which would include installing giant freezers inside a mountain at the North Pole. &lt;/p&gt;&lt;p&gt;In the newsjam, we look at plans for &lt;a href="http://www.guardian.co.uk/uk/video/2009/aug/04/adonis-high-speed-rail"&gt;high-speed rail in the UK&lt;/a&gt;, the &lt;a href="http://www.guardian.co.uk/science/blog/2009/aug/04/population-climate-change-birth-rates"&gt;carbon footprint of babies&lt;/a&gt;, what triggers &lt;a href="http://www.guardian.co.uk/science/blog/2009/aug/05/gecko-grip-adhesion-gravity"&gt;geckos' famous grip&lt;/a&gt;, and why &lt;a href="http://www.guardian.co.uk/environment/2009/aug/05/affordable-beekeeping-beehaus"&gt;beekeeping is becoming the latest craze&lt;/a&gt;. &lt;/p&gt;&lt;p&gt;Tents, scruffy people, mud, primitive latrines ... and quantum physics? A group called &lt;a href="http://www.guerillascience.co.uk"&gt;Guerilla Science&lt;/a&gt; has been pitching both its tent – and a scientific message. &lt;strong&gt;Frank Swain&lt;/strong&gt; reports from the Latitude festival as the scientists got down and dirty with the revellers.     &lt;/p&gt;&lt;p&gt;The Guardian's Science Book Club has been tackling &lt;a href="http://www.guardian.co.uk/science/2009/jul/30/stephen-hawking-brief-history-time"&gt;Stephen Hawking's A Brief History of Time&lt;/a&gt;. Our literary guru &lt;strong&gt;Tim Radford&lt;/strong&gt; kicked off proceedings and stirred up a hornet's nest by suggesting that one of the ingredients for the book's phenomenal success might be Hawking's boast that he was trying to "understand the mind of god". &lt;/p&gt;&lt;p&gt;Post your comments about this programme on the blog below.&lt;/p&gt;&lt;p&gt;Join our &lt;a href="http://www.facebook.com/group.php?gid=2261841960"&gt;Facebook group&lt;/a&gt;. &lt;/p&gt;&lt;p&gt;Listen back through &lt;a href="http://www.guardian.co.uk/scienceweekly"&gt;our archive&lt;/a&gt;.&lt;/p&gt;&lt;p&gt;Follow us on &lt;a href="http://twitter.com/guardianscience"&gt;our Twitter feed&lt;/a&gt;.&lt;/p&gt;&lt;p&gt;Subscribe free &lt;a href="http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewPodcast?id=136697669"&gt;via iTunes&lt;/a&gt; to ensure every episode gets delivered. (Here is the &lt;a href="http://www.guardian.co.uk/science/series/science/rss"&gt;non-iTunes URL feed&lt;/a&gt;).&lt;/p&gt;&lt;div class="author"&gt;&lt;a href="http://www.guardian.co.uk/profile/alokjha"&gt;Alok Jha&lt;/a&gt;&lt;/div&gt;&lt;div class="author"&gt;&lt;a href="http://www.guardian.co.uk/profile/andyduckworth"&gt;Andy Duckworth&lt;/a&gt;&lt;/div&gt;&lt;div class="author"&gt;&lt;a href="http://www.guardian.co.uk/profile/jamesranderson"&gt;James Randerson&lt;/a&gt;&lt;/div&gt;&lt;div class="author"&gt;&lt;a href="http://www.guardian.co.uk/profile/jameskingsland"&gt;James Kingsland&lt;/a&gt;&lt;/div&gt;&lt;br/&gt;&lt;p style="clear:both" /&gt;))
            channel_item.category({:domain => 'http://www.guardian.co.uk/science'}, 'Science')
            channel_item.pubDate('Sun, 09 Aug 2009 23:01:00 GMT')
            channel_item.guid('http://www.guardian.co.uk/science/audio/2009/aug/10/science-weekly-podcast-seeds-biodiversity')
            channel_item.media(:content, {'height'=>"84", 'type'=>"image/jpeg", 'width'=>"140", 'url'=>"http://static.guim.co.uk/sys-images/Environment/Pix/pictures/2007/07/23/oilseed1b.jpg"}) { |content| 
              content.media(:credit, {:scheme => 'urn:ebu'}, 'Christopher Furlong/Getty')
              content.media(:description, 'The sun sets over a field of rapeseed')
            }
            channel_item.media(:content, {'duration'=>"784", 'fileSize'=>"12611407", \
                                          'type' => enclosure_format_type, 
                                          'url'=>"http://download.guardian.co.uk/audio/kip/science/series/science/1249655385631/8643/gdn.sci.090810.ad.Science-Weekly-podcast.mp3"})
          }
        }
      }
      flexmock(Feedzirra::Feed, :decode_content => expected_feed_xml)
      expected_tags = ['science']
      expected_duration = (784/60)
      expected_podcast = Podcast.build('http://download.guardian.co.uk/audio/kip/science/series/science/1249655385631/8643/gdn.sci.090810.ad.Science-Weekly-podcast.mp3', %Q(Science Weekly podcast: Backing up the Earth's biodiversity), %Q(&lt;p&gt;&lt;strong&gt;Cary Fowler&lt;/strong&gt; from the &lt;a href="http://www.croptrust.org/main/"&gt;Global Crop Diversity Trust&lt;/a&gt; discusses his plans to develop a global system for &lt;a href="http://www.guardian.co.uk/media/pda/2009/jul/22/climate-change-agriculture"&gt;conserving the biodiversity of all agricultural crops&lt;/a&gt;, which would include installing giant freezers inside a mountain at the North Pole. &lt;/p&gt;&lt;p&gt;In the newsjam, we look at plans for &lt;a href="http://www.guardian.co.uk/uk/video/2009/aug/04/adonis-high-speed-rail"&gt;high-speed rail in the UK&lt;/a&gt;, the &lt;a href="http://www.guardian.co.uk/science/blog/2009/aug/04/population-climate-change-birth-rates"&gt;carbon footprint of babies&lt;/a&gt;, what triggers &lt;a href="http://www.guardian.co.uk/science/blog/2009/aug/05/gecko-grip-adhesion-gravity"&gt;geckos' famous grip&lt;/a&gt;, and why &lt;a href="http://www.guardian.co.uk/environment/2009/aug/05/affordable-beekeeping-beehaus"&gt;beekeeping is becoming the latest craze&lt;/a&gt;. &lt;/p&gt;&lt;p&gt;Tents, scruffy people, mud, primitive latrines ... and quantum physics? A group called &lt;a href="http://www.guerillascience.co.uk"&gt;Guerilla Science&lt;/a&gt; has been pitching both its tent – and a scientific message. &lt;strong&gt;Frank Swain&lt;/strong&gt; reports from the Latitude festival as the scientists got down and dirty with the revellers.     &lt;/p&gt;&lt;p&gt;The Guardian's Science Book Club has been tackling &lt;a href="http://www.guardian.co.uk/science/2009/jul/30/stephen-hawking-brief-history-time"&gt;Stephen Hawking's A Brief History of Time&lt;/a&gt;. Our literary guru &lt;strong&gt;Tim Radford&lt;/strong&gt; kicked off proceedings and stirred up a hornet's nest by suggesting that one of the ingredients for the book's phenomenal success might be Hawking's boast that he was trying to "understand the mind of god". &lt;/p&gt;&lt;p&gt;Post your comments about this programme on the blog below.&lt;/p&gt;&lt;p&gt;Join our &lt;a href="http://www.facebook.com/group.php?gid=2261841960"&gt;Facebook group&lt;/a&gt;. &lt;/p&gt;&lt;p&gt;Listen back through &lt;a href="http://www.guardian.co.uk/scienceweekly"&gt;our archive&lt;/a&gt;.&lt;/p&gt;&lt;p&gt;Follow us on &lt;a href="http://twitter.com/guardianscience"&gt;our Twitter feed&lt;/a&gt;.&lt;/p&gt;&lt;p&gt;Subscribe free &lt;a href="http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewPodcast?id=136697669"&gt;via iTunes&lt;/a&gt; to ensure every episode gets delivered. (Here is the &lt;a href="http://www.guardian.co.uk/science/series/science/rss"&gt;non-iTunes URL feed&lt;/a&gt;).&lt;/p&gt;&lt;div class="author"&gt;&lt;a href="http://www.guardian.co.uk/profile/alokjha"&gt;Alok Jha&lt;/a&gt;&lt;/div&gt;&lt;div class="author"&gt;&lt;a href="http://www.guardian.co.uk/profile/andyduckworth"&gt;Andy Duckworth&lt;/a&gt;&lt;/div&gt;&lt;div class="author"&gt;&lt;a href="http://www.guardian.co.uk/profile/jamesranderson"&gt;James Randerson&lt;/a&gt;&lt;/div&gt;&lt;div class="author"&gt;&lt;a href="http://www.guardian.co.uk/profile/jameskingsland"&gt;James Kingsland&lt;/a&gt;&lt;/div&gt;&lt;br/&gt;&lt;p style="clear:both" /&gt;), expected_duration, 
      'http://www.guardian.co.uk/science/audio/2009/aug/10/science-weekly-podcast-seeds-biodiversity', expected_tags, 'Sun, 09 Aug 2009 23:01:00 GMT', 12611407)
    
      testee = PodcastCollector.new([FEED_URI])
      testee.collect_podcasts
      assert_equal([expected_podcast], testee.collected_podcasts)
    end
  end
  
  def test_collects_podcasts_from_media_and_dublin_core_tagged_rss_feeds
    ['audio/mpeg', 'audio/mp3'].each do |enclosure_format_type|
      builder = Builder::XmlMarkup.new
      builder.instruct! :xml, :version => "1.0"
      expected_feed_xml = builder.rss('version' => '2.0', 
        'xmlns:media' => 'http://search.yahoo.com/mrss/',
        'xmlns:dc' => 'http://purl.org/dc/elements/1.1/') { |feed| 
        feed.channel {|channel|
          channel.title('Science: Science + Audio | guardian.co.uk')
          channel.link('http://www.guardian.co.uk/science/science+content/audio')
          channel.item { |channel_item|
            channel_item.title(%Q(Science Weekly podcast: Backing up the Earth's biodiversity))
            channel_item.link('http://www.guardian.co.uk/science/audio/2009/aug/10/science-weekly-podcast-seeds-biodiversity')
            channel_item.description(%Q(interesting description))
            channel_item.category({:domain => 'http://www.guardian.co.uk/science'}, 'Science')
            channel_item.pubDate('Sun, 09 Aug 2009 23:01:00 GMT')
            channel_item.guid('http://www.guardian.co.uk/science/audio/2009/aug/10/science-weekly-podcast-seeds-biodiversity')
            channel_item.dc(:creator, 'Alok Jha, Andy Duckworth, James Randerson, James Kingsland')
            channel_item.dc(:subject, 'Science')
            channel_item.dc(:date, '2009-08-16T22:59:58Z')
            channel_item.dc(:type, 'Audio')
            channel_item.media(:content, {'duration'=>"784", 'fileSize'=>"12611407", \
                                          'type' => enclosure_format_type, \
                                          'url'=>"http://download.guardian.co.uk/audio/kip/science/series/science/1249655385631/8643/gdn.sci.090810.ad.Science-Weekly-podcast.mp3"})
          }
        }
      }
      flexmock(Feedzirra::Feed, :decode_content => expected_feed_xml)
      expected_tags = ['science', 'alok_jha', 'andy_duckworth', 'james_randerson', 'james_kingsland']
      expected_duration = (784/60)
      expected_podcast = Podcast.build('http://download.guardian.co.uk/audio/kip/science/series/science/1249655385631/8643/gdn.sci.090810.ad.Science-Weekly-podcast.mp3', %Q(Science Weekly podcast: Backing up the Earth's biodiversity), %Q(interesting description), expected_duration, 
      'http://www.guardian.co.uk/science/audio/2009/aug/10/science-weekly-podcast-seeds-biodiversity', expected_tags, 'Sun, 09 Aug 2009 23:01:00 GMT', 12611407)
    
      testee = PodcastCollector.new([FEED_URI])
      testee.collect_podcasts
      assert_equal([expected_podcast], testee.collected_podcasts)
    end
  end
end