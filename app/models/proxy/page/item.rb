class Proxy::Page::Item < Proxy::Page
  
  def item=(i)
    @item = i
  end
  
  def item
    @item
  end
  
  def type
    item.class.name            
  end
  
  def navigations
    item.collection.navigations
  end
  
  def template
    @template ||= TemplateFile.new(item.collection.template_path + "/" + template_file)
  end
  
  def body_class
    item.class.name.tableize.singularize
  end
  
  def url
    @url ||= item.url
  end
  
  def url=(url)
    @url = url
  end
  
  
end