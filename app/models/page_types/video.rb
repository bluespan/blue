class PageTypes::Video < Page
  
  has_one :video
  
  configure_blue_page do |page| 
    page.type_name = "Video"
  end

end