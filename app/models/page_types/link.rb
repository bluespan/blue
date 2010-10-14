class PageTypes::Link < Page
  validates_presence_of :url
  
  configure_blue_page do |page| 
    page.type_name = "Link"
  end
  
  
  def url
    self[:url]
  end
  
  def link
    url
  end
  
  def open_new_window?
    self[:open_new_window]
  end
  
  def template
    false
  end
  
end
