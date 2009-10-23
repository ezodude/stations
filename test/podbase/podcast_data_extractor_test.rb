# encoding: utf-8

require "test/unit"
require 'flexmock/test_unit'

class PodcastCollectorTest < Test::Unit::TestCase
  def setup
    @testee = Object.new
    @testee.extend(SaidFm::PodcastDataExtractorUtils)
  end
  
  def test_collects_keywords_from_categories
    keyword_holder = flexmock('entry', :categories => ['Science', 'Biodiversity'], :itunes_keywords => nil)
    assert_equal(['Science', 'Biodiversity'], @testee.collect_any_keywords_from(keyword_holder))
  end
  
  def test_collects_keywords_from_itunes_keywords
    keyword_holder = flexmock('entry', :categories => nil, :itunes_keywords => 'personalTechnology,,privacy')
    assert_equal(['personalTechnology', 'privacy'], @testee.collect_any_keywords_from(keyword_holder))
  end
  
  def test_collects_and_combines_keywords_from_both_categories_and_itunes_keywords
    keyword_holder = flexmock('entry', :categories => ['Science', 'Biodiversity'], :itunes_keywords => 'personalTechnology,privacy')
    assert_equal(['Science', 'Biodiversity', 'personalTechnology', 'privacy'], @testee.collect_any_keywords_from(keyword_holder))
  end
  
  def test_accomodates_undefined_methods_for_certain_holders
    keyword_holder = flexmock('entry', :categories => ['Science', 'Biodiversity'])
    assert_equal(['Science', 'Biodiversity'], @testee.collect_any_keywords_from(keyword_holder))
    
    keyword_holder = flexmock('entry', :itunes_keywords => 'personalTechnology,privacy')
    assert_equal(['personalTechnology', 'privacy'], @testee.collect_any_keywords_from(keyword_holder))
  end
  
  def test_tagifies_various_formats
    values = ['Carbon footprints', 'guardian.co.uk', 'personalTechnology', 'privacy']
    expected = ['carbon_footprints', 'guardian_co_uk', 'personal_technology', 'privacy']
    assert_equal(expected, @testee.tagify(values))
  end
  
  def test_determines_duration_in_minutes_from_hh_mm_ss_format_when_no_hours_available
    entry = flexmock('entry', :itunes_duration => '00:31:21', :media_duration => nil)
    assert_equal(31, @testee.determine_duration_from(entry))
  end
  
  def test_determines_duration_in_minutes_from_hh_mm_ss_format_when_hours_are_available
    entry = flexmock('entry', :itunes_duration => '1:31:21', :media_duration => nil)
    assert_equal(91, @testee.determine_duration_from(entry))
  end
  
  def test_determines_duration_in_minutes_from_mm_ss_format
    entry = flexmock('entry', :itunes_duration => '31:21', :media_duration => nil)
    assert_equal(31, @testee.determine_duration_from(entry))
  end
  
  def test_determines_duration_in_minutes_from_mm_ss_format_when_minutes_exceed_60
    entry = flexmock('entry', :itunes_duration => '63:21', :media_duration => nil)
    assert_equal(63, @testee.determine_duration_from(entry))
  end
  
  def test_determines_duration_in_minutes_from_seconds_based_duration
    entry = flexmock('entry', :media_duration => '1866', :itunes_duration => nil)
    assert_equal(31, @testee.determine_duration_from(entry))
  end
end