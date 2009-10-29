# encoding: utf-8

class Tag
  include DataMapper::Resource
  
  property :id, String, :length => 200, :key => true, :unique => true
  property :title, String, :length => 200, :nullable => false, :unique => true
  property :created_at, Time
  property :updated_at, Time
  
  has n, :classifications
  has n, :podcasts, :through => :classifications
  
  def self.build_with(tag_title)
    self.new(:id => UUIDTools::UUID.random_create, :title => tag_title)
  end
  
  def to_s
    "#{id}::#{title}"
  end
end