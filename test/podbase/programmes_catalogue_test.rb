# encoding: utf-8

require "test/unit"
require 'flexmock/test_unit'

class ProgrammesCatalogueTest < Test::Unit::TestCase
  def test_returns_jsonified_tag_with_the_same_title_as_searched_for_keyword
    mock_tag = flexmock(Tag.new, :id => 'some-unique-id', :title => 'keyword')
    flexmock(Tag).should_receive(:first).with(:title => 'keyword').returns(mock_tag)
    
    expected = { 'id' => 'some-unique-id', 'title' => 'keyword' }.to_json
    assert_equal(expected, ProgrammesCatalogue.related_tag_for_keyword('keyword'))
  end
  
  def test_returns_nil_when_no_tag_found_matching_keyword
    flexmock(Tag).should_receive(:first).with(:title => 'keyword').returns(nil)
    assert_nil(ProgrammesCatalogue.related_tag_for_keyword('keyword'))
  end
  
  def test_returns_jsonified_list_of_programmes_related_to_a_tag
    fake_time = Time.now.utc
    mock_podcast = flexmock(Podcast.new, :id => 'some-id', :audio_uri => 'http://www.audio.uri/1.mp3', :title => 'title', 
                            :summary => 'summary', :published_at => fake_time, :source_uri => "http://www.audio.uri/source/")
    mock_tag1 = flexmock(Tag.new, :id => 'tag1-id', :title => 'tag1-title')
    mock_tag2 = flexmock(Tag.new, :id => 'tag2-id', :title => 'tag2-title')
    
    mock_podcast.should_receive(:tags).returns([mock_tag1, mock_tag2])
    mock_tag1.should_receive(:podcasts).returns([mock_podcast])
    
    flexmock(Tag).should_receive(:get).with('tag1-id').returns(mock_tag1)
        
    expected_programmes = [
      {
        'id' => 'some-id', 'audio_uri' => 'http://www.audio.uri/1.mp3', 'title' => 'title', 'summary' => 'summary', 
        'tags' => 'tag1-id::tag1-title,tag2-id::tag2-title', 'published_at' => fake_time.to_date.to_json, 'source_uri' => "http://www.audio.uri/source/"
      }.to_json
    ].to_json
    
    assert_equal(expected_programmes, ProgrammesCatalogue.programmes_for_tag('tag1-id'))
  end
  
  def test_returns_no_more_than_5_programmes_per_jsonified_list_related_to_a_tag
    mock_podcast1 = flexmock(Podcast.new, :id => "podcast1-id", :audio_uri => "http://www.audio.uri/1.mp3", :title => 'title', :summary => 'summary')
    mock_podcast2 = flexmock(Podcast.new, :id => "podcast2-id", :audio_uri => "http://www.audio.uri/2.mp3", :title => 'title', :summary => 'summary')
    mock_podcast3 = flexmock(Podcast.new, :id => "podcast3-id", :audio_uri => "http://www.audio.uri/3.mp3", :title => 'title', :summary => 'summary')
    mock_podcast4 = flexmock(Podcast.new, :id => "podcast4-id", :audio_uri => "http://www.audio.uri/4.mp3", :title => 'title', :summary => 'summary')
    mock_podcast5 = flexmock(Podcast.new, :id => "podcast5-id", :audio_uri => "http://www.audio.uri/5.mp3", :title => 'title', :summary => 'summary')
    mock_podcast6 = flexmock(Podcast.new, :id => "podcast6-id", :audio_uri => "http://www.audio.uri/6.mp3", :title => 'title', :summary => 'summary')
    
    mock_tag1 = flexmock(Tag.new, :id => 'tag1-id', :title => 'tag1-title')
    mock_tag2 = flexmock(Tag.new, :id => 'tag2-id', :title => 'tag2-title')
    
    mock_podcast1.should_receive(:tags).returns([mock_tag1, mock_tag2])
    mock_podcast2.should_receive(:tags).returns([mock_tag1, mock_tag2])
    mock_podcast3.should_receive(:tags).returns([mock_tag1, mock_tag2])
    mock_podcast4.should_receive(:tags).returns([mock_tag1, mock_tag2])
    mock_podcast5.should_receive(:tags).returns([mock_tag1, mock_tag2])
    mock_podcast6.should_receive(:tags).returns([mock_tag1, mock_tag2])
    
    mock_tag1.should_receive(:podcasts).returns([mock_podcast1, mock_podcast2, mock_podcast3, mock_podcast4, mock_podcast5, mock_podcast6])
    
    flexmock(Tag).should_receive(:get).with('tag1-id').returns(mock_tag1)
    expected_programmes = [mock_podcast1, mock_podcast2, mock_podcast3, mock_podcast4, mock_podcast5].collect{|p| p.to_json}.to_json
    
    assert_equal(5, JSON.parse(ProgrammesCatalogue.programmes_for_tag('tag1-id')).length)
    assert_equal(expected_programmes, ProgrammesCatalogue.programmes_for_tag('tag1-id'))
  end
  
  def test_filters_programmes_based_on_attached_exclusion_list
    mock_podcast1 = flexmock(Podcast.new, :id => "podcast1-id", :audio_uri => "http://www.audio.uri/1.mp3", :title => 'title', :summary => 'summary')
    mock_podcast2 = flexmock(Podcast.new, :id => "podcast2-id", :audio_uri => "http://www.audio.uri/2.mp3", :title => 'title', :summary => 'summary')
    mock_podcast3 = flexmock(Podcast.new, :id => "podcast3-id", :audio_uri => "http://www.audio.uri/3.mp3", :title => 'title', :summary => 'summary')
    
    mock_tag1 = flexmock(Tag.new, :id => 'tag1-id', :title => 'tag1-title')
    
    mock_podcast1.should_receive(:tags).returns([mock_tag1])
    mock_podcast2.should_receive(:tags).returns([mock_tag1])
    mock_podcast3.should_receive(:tags).returns([mock_tag1])
    
    mock_tag1.should_receive(:podcasts).returns([mock_podcast1, mock_podcast2, mock_podcast3])
    
    flexmock(Tag).should_receive(:get).with('tag1-id').returns(mock_tag1)
    expected_programmes = [mock_podcast1, mock_podcast3].collect{|p| p.to_json}.to_json
    
    assert_equal(2, JSON.parse(ProgrammesCatalogue.programmes_for_tag('tag1-id', ['podcast2-id'])).length)
    assert_equal(expected_programmes, ProgrammesCatalogue.programmes_for_tag('tag1-id', ['podcast2-id']))
  end
  
  def test_returns_empty_jsonified_list_when_there_no_programmes_available
    mock_tag1 = flexmock(Tag.new, :id => 'tag1-id', :title => 'tag1-title')
    mock_tag1.should_receive(:podcasts).returns([])
    
    flexmock(Tag).should_receive(:get).with('tag1-id').returns(mock_tag1)
    assert_equal([].to_json, ProgrammesCatalogue.programmes_for_tag('tag1-id'))
  end
end