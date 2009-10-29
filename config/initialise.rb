require 'rubygems'
require 'json'
require 'uuid'
require 'activesupport'
require 'feedzirra'
require 'datamapper_config'
require 'podcast_data_extractor_utils'
require 'podcast_collector'
require 'programmes_catalogue'
require 'builder'
require 'uuidtools'

FEEDS = [
  "http://www.uie.com/brainsparks/feed/",
  "http://www.nytimes.com/services/xml/rss/nyt/podcasts/techtalk.xml",
  "http://www.nytimes.com/services/xml/rss/nyt/podcasts/musicreview.xml",
  "http://www.gillespetersonworldwide.com/podcasts/gillespeterson.rss",
  "http://www.nytimes.com/services/xml/rss/nyt/podcasts/scienceupdate.xml",
  "http://rss.conversationsnetwork.org/series/innovators.xml",
  "http://rss.conversationsnetwork.org/series/technation.xml",
  "http://rss.conversationsnetwork.org/series/technometria.xml",
  "http://feeds.feedburner.com/TheSemanticWebGang?format=xml",
  "http://www.stanford.edu/group/edcorner/uploads/podcast/EducatorsCorner.xml",
  "http://www.venturevoice.com/vv.xml",
  "http://feeds.feedburner.com/TheStartupSuccessPodcast",
  "http://www.guardian.co.uk/science/series/science/rss",
  "http://www.guardian.co.uk/technology/series/techweekly/rss",
  "http://feeds.feedburner.com/tedtalks_audio.xml",
  "http://librarygang.talis.com/feed/",
  "http://blogs.talis.com/nodalities/podcast/",
  "http://leoville.tv/podcasts/itn.xml",
  "http://www.blogtalkradio.com/maketalk.rss",
  "http://www.npr.org/rss/podcast.php?id=510053"
]