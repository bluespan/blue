class AdminSession < Authlogic::Session::Base
  authenticate_with AdminUser
  
  def self.self_and_descendants_from_active_record
   [self]
  end
  def self.human_attribute_name(attribute_key_name, options = {})
   defaults = self_and_descendants_from_active_record.map do |klass|
     "#{klass.name.underscore}.#{attribute_key_name}""#{klass.name.underscore}.#{attribute_key_name}"
   end
   defaults << options[:default] if options[:default]
   defaults.flatten!
   defaults << attribute_key_name.humanize
   options[:count] ||= 1
   I18n.translate(defaults.shift, options.merge(:default => defaults, :scope => [:activerecord, :attributes]))
  end
  def self.human_name(options = {})
   defaults = self_and_descendants_from_active_record.map do |klass|
     "#{klass.name.underscore}""#{klass.name.underscore}"
   end 
   defaults << self.name.humanize
   I18n
  end
end