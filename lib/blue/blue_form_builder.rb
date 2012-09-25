class BlueFormBuilder < ActionView::Helpers::FormBuilder

  def text_field(method, options = {})
    return readonly_text_field(method, options) if options[:readonly]
    field_name, label, options = field_settings(method, options)
    wrapping("text", method, field_name, label, super, options)
  end

  def readonly_text_field(method, options = {}) 
    field_name, label, options = field_settings(method, options)
    value = options[:value] || object.send(method)
    classes = "readonly #{options[:class]}"
    classes += " blank" if value.blank?
    wrapping("span", method, field_name, label, "<span id='#{field_name}' class='#{classes}'>#{value}</span>", options)
  end

  def file_field(method, options = {})
    field_name, label, options = field_settings(method, options)
    wrapping("file", method, field_name, label, super, options)
  end

  def datetime_select(method, options = {})
    value = @object.send(method).nil? ? "" : @object.send(method).strftime("%Y-%m-%d %I:%M:%S %p")
    return readonly_text_field(method, {:value => value}.merge(options)) if options[:readonly]
    field_name, label, options = field_settings(method, options)
    wrapping("datetime", method, field_name, label, super, options)
  end

  def date_select(method, options = {})    
    value = @object.send(method).nil? ? "" : @object.send(method).strftime("%Y-%m-%d")
    return readonly_text_field(method, {:value => value}.merge(options)) if options[:readonly]
    field_name, label, options = field_settings(method, options)
    wrapping("date", method, field_name, label, super, options)
  end

  def radio_button(method, tag_value, options = {})    
    field_name, label, options = field_settings(method, options, tag_value)
    wrapping("radio", method, field_name, label, super, options)
  end

  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    field_name, label, options = field_settings(method, options)
    wrapping("check-box", method, field_name, label, super, options)
  end

  def select(method, choices, options = {}, html_options = {})
    return readonly_text_field(method, {:value => choices.select { |c| c[1] == @object.send(method)}.first.first }.merge(options)) if options[:readonly]
    field_name, label, options = field_settings(method, options)
    wrapping("select", method, field_name, label, super, options)
  end

  def password_field(method, options = {})
    field_name, label, options = field_settings(method, options)
    wrapping("password", method, field_name, label, super, options)
  end

  def text_area(method, options = {})
    return readonly_text_field(method, options) if options[:readonly]
    field_name, label, options = field_settings(method, options)
    wrapping("textarea", method,  field_name, label, super, options)
  end

  def submit(method, options = {})
    field_name, label, options = field_settings(method, options)
    wrapping("submit", method, field_name, label, super(method, options.merge({:class => "button submit"})), options )
  end
  
  private

  def field_settings(method, options = {}, tag_value = nil)
    field_name = "#{@object_name}_#{method.to_s}" 
    field_name += "_#{tag_value.to_s}" unless tag_value.nil?
    default_label = tag_value.nil? ? "#{method.to_s.gsub(/\_/, " ")}" : "#{tag_value.to_s.gsub(/\_/, " ")}" 
    label = options[:label] ? options.delete(:label) : default_label
    options[:class] ||= "" 
    options[:class] += options[:required] ? " required" : "" 
    options[:class] += (@object.errors.on(method) || @object.errors.on((method.to_s+"_file_size").to_sym) || @object.errors.on((method.to_s+"_content_type").to_sym)) ? " error" : ""

    label += "<strong><sup>*</sup></strong>" if options[:required]
    options.delete(:required) unless options[:required] == true
    [field_name, label, options]
  end


  def wrapping(type, method, field_name, label, field, options = {})
   to_return = []
   to_return << %Q{<div class="field #{type}-field #{options[:class]}">}
   to_return << %Q{<label for="#{field_name}">#{label}</label>} unless ["radio","check-box", "submit"].include?(type) or label.blank?
   to_return << %Q{<p class="description">#{options[:description]}</p>} if options[:description] && ["radio","check-box"].include?(type) == false
   to_return << %Q{<div class="input">}
   to_return << field
   to_return << %Q{<label for="#{field_name.downcase.gsub(/ /, "_")}">#{label}</label>} if ["radio","check-box"].include?(type)    
   to_return << %Q{<p class="description">#{options[:description]}</p>} if options[:description] && ["radio","check-box"].include?(type)
   errors = []
   errors << @object.errors.on(method)
   errors << @object.errors.on((method.to_s+"_file_size").to_sym)
   errors << @object.errors.on((method.to_s+"_content_type").to_sym)
   errors = errors.flatten.compact
   if errors.length and @options[:inline_errors]
		 to_return << %Q{<ul class="error_messages">#{errors.collect { |e| "<li>#{e}</li>"} }</ul>}
   end
   to_return << %Q{</div></div>}
  end
  
end