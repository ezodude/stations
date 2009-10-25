class ProgrammesCatalogue
  MAX_PROGRAMMES_PER_PACKAGE = 5
  
  def self.related_tag_for_keyword(keyword)
    found_tag = Tag.first(:title => keyword)
    { 'id' => found_tag.id, 'title' => found_tag.title }.to_json if found_tag
  end
  
  def self.programmes_for_tag(tag_id, exclusion_list=[])
    tag = Tag.get(tag_id)
    programmes = tag.podcasts
    
    programmes = jsonify_and_exclude(programmes, exclusion_list)
    package(programmes, exclusion_list).to_json
  end

private
  def self.jsonify_and_exclude(programmes, to_exclude=[])
    programmes.collect{|p| p.to_json unless to_exclude.include?(p.id)}.compact
  end
  
  def self.package(programmes, to_exclude=[])
    programmes.slice(0, MAX_PROGRAMMES_PER_PACKAGE)
  end
end