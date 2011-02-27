require 'activerecord'

module Blue
  module Has 
    module LocalizedData

      def self.included(base)
        base.extend ClassMethods # if blue_features.include?(:localization)
      end
      
      module ClassMethods
        def has_localized_data
          serialize :locale_data
          include Blue::Has::LocalizedData::InstanceMethods
        end
        
      end
      
      module InstanceMethods
        
        def l10n_attribute(attribute, locale = nil, default = nil)
          return self.send(attribute.to_sym) unless Span::Blue.features.include?(:localization) && self.respond_to?(:locale_data)
          self.locale_data = {} unless locale_data.is_a?(Hash)
          
          locale = I18n.locale if locale.nil?
          locale = locale.to_s
          if locale_data.has_key?(attribute.to_s) and locale_data[attribute.to_s].has_key?(locale) and locale_data[attribute.to_s][locale].blank? == false
            return locale_data[attribute.to_s][locale]
          else
            return default || self.send("locale_#{attribute.to_s}".to_sym)
          end
        end
        
        def locale_enabled
          self.new_record?
        end
        
        def locale_title
          title
        end
        
      end
      

    end
  end
end



ActiveRecord::Base.send(:include, Blue::Has::LocalizedData)