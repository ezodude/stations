# encoding: utf-8

class Tag
  include DataMapper::Resource
  
  property :id, String, :key => true, :unique => true
  property :title, String, :nullable => false, :unique => true
  property :created_at, Time
  property :updated_at, Time
  
  has n, :classifications
  has n, :podcasts, :through => :classifications
  
  def self.build_with(tag_title)
    self.new(:id => UUID.generate, :title => tag_title)
  end
end