class Collection < Page

  configure_blue_page do |page| 
    page.type_name = "Collection"
  end
  
  def template_path
    sub_dir = self.collects.tableize
    RAILS_ROOT + "/app/views/" + sub_dir + "/"
  end
  
  def template
    @template ||= TemplateFile.new(template_path + "/index.html.erb")
  end
  
  def body_class
    return "collection #{collects}"
  end
  
  class << self
    
    def css_class
      "collection"
    end
    
    def destroyable?
      false
    end
    
    def page_for(collection_type)
      find(:first,  :conditions => {:collects => collection_type.to_s})
    end
  end

end
