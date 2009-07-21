class PageTypes::HomePage < Page
  
  configure_blue_page do |page| 
    page.type_name = "Home Page"
  end
  
  def template
    @template ||= TemplateFile.find('/home_page/home.html.erb')
  end
  
end