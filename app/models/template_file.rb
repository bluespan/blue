class TemplateFile < File
  
  def self.humanize(name)
    name = name[/^.+\/([^\/\.]+)\.(.+)$/, 1]
    if name
      # Capitalize each word and change _ to a space
      name.gsub!(/(^|[_-]+)([A-Za-z0-9]+)/) { |match| " #{$2.capitalize}"}
      name.strip!
    end
    
    return name.gsub(' ', "_").downcase
  end
  
  def humanize
    TemplateFile.humanize(path)
  end
  
  def name
    path[/^.+\/([^\/]+)$/, 1]
  end
  
  def css_class
    humanize.gsub(' ', "_").downcase
  end
  
  def self.find(template, mode = 'r')
    if template == :all
      templates = []
      
      Dir.new(BLUE_TEMPLATE_ROOT).each do |file|
        templates << TemplateFile.new(BLUE_TEMPLATE_ROOT + file, mode) unless file[/^\..*$/] or File.directory?(BLUE_TEMPLATE_ROOT + file)
      end
      
      return templates 
    else
      raise BlueTempateFileNotFound.new(:path => BLUE_TEMPLATE_ROOT, :template_file => template) unless TemplateFile.exist?(BLUE_TEMPLATE_ROOT + template)
      TemplateFile.new(BLUE_TEMPLATE_ROOT + template, mode)
    end
  end
  
end