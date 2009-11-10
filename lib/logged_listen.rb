class LoggedListen
  include DataMapper::Resource
  
  property :id, Serial
  timestamps :at
  
  belongs_to :tracked_listener
  belongs_to :broadcastable_programme
  
  def ==(other)
    other.tracked_listener.id == tracked_listener.id && other.broadcastable_programme.id == broadcastable_programme.id
  end
end