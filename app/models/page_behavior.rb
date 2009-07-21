BLUE_PAGE_BEHAVIOR_ROOT = RAILS_ROOT + "app/models/page_behaviors"
class PageBehavior
  
  def self.find(page_behavior, mode = 'r')
    if page_behavior == :all
      page_behaviors = []
      
      Dir.new(BLUE_PAGE_BEHAVIOR_ROOT).each do |file|
        page_behaviors << file
      end
      
      return templates 
    else
      TemplateFile.new(BLUE_TEMPLATE_ROOT + template, mode)
    end
  end
  
end