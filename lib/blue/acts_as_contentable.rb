require 'activerecord'

module Blue
  module Acts 
    module Contentable

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_contentable
          has_many :content, :as => :contentable, :dependent => :destroy do
            def to_hash(type)
              array_of_type = self.select { |c| c.type == type.to_s }
              hash = {}
              
              array_of_type.each do |c|
                title = c.title.to_sym
                locale = c.locale.to_s
                hash[title] = {} unless hash.has_key?(title)
                hash[title][locale] = {} unless hash[title].has_key?(locale)
                hash[title][locale] = c
              end
                
              def hash.set_verbiage(key, locale, value)
                locale = locale.to_s
                key = key.to_sym
                if self.has_key?(key) && self[key].has_key?(locale)
                  self[key][locale].update_attributes({:content => value})
                else
                  self[key] = {} unless self.has_key?(key)
                  self[key][locale] = {} unless self[key].has_key?(locale)
                  self[key][locale] = Verbiage.new({:title => key.to_s, :content => value, :locale => locale})

                  @contentable.content << self[key][locale]                  
                end
                
                self[key][locale]
              end
              
              # hash = Hash[* self.select { |c| c.type == type.to_s }.collect { |c| [c.title.to_sym, {c.locale => c}] }.flatten]
              
              def hash.contentable=(contentable)
                @contentable = contentable
              end
              hash.contentable = proxy_owner
              
              hash
            end              
          end
          
          include Blue::Acts::Contentable::InstanceMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
      end
      
      # This module contains instance methods
      module InstanceMethods
        
        def verbiage
          @verbiage ||= content.to_hash(Verbiage)
          @verbiage
        end
        
        def verbiage=(verbiage_hash)
          verbiage_hash.each do | key, val |
            val.each do |locale, value|
              verbiage.set_verbiage(key, locale, value)
            end
          end
        end
      end
      
    end
  end
end

ActiveRecord::Base.send(:include, Blue::Acts::Contentable)
