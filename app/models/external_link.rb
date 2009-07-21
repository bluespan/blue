class ExternalLink < Page
  validates_presence_of :url
  
  def generate_unique_slug!
    self[:slug] = "#{self[:title]}-#{self[:url]}"
  end
  
  def url
    self[:url]
  end
  
end
