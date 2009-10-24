# encoding: utf-8

class Classification
  include DataMapper::Resource
  
  property :id, Serial
  property :created_at, Time
  property :updated_at, Time
  
  belongs_to :podcast
  belongs_to :tag
  
  before :save do
    if self.tag.new?
      raise RuntimeError.new("Classification could not be created for tag [#{self.tag}]") unless self.tag.save
    end
  end
  
  def self.build_with(candidate_tag=nil)
    tag = Tag.first(:title => candidate_tag)
    tag = Tag.build_with(candidate_tag) if tag.nil?
    self.new(:tag => tag)
  end
end