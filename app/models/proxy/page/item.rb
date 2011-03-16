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
    @template ||= find_template
  end
  
  def find_template
    item.class.view_paths.each do |view_path|
      if TemplateFile.exist?(view_path + "/" + template_file)
        return TemplateFile.new(view_path + "/" + template_file)
      end
    end
    
    TemplateFile.new(item.class.view_paths.first + "/" + template_file)
  end
  
  def body_class
    c = item.class
    classes = [c.name.tableize.singularize]
    while c.superclass and c.superclass != ActiveRecord::Base
       c = c.superclass
       classes << c.name.tableize.singularize
    end
    classes.join(" ")
  end
  
  def url
    @url ||= item.url
  end
  
  def url=(url)
    @url = url
  end
  
  
end