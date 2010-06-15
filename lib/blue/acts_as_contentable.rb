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
              hash = Hash[* self.select { |c| c.type == type.to_s }.collect { |c| [c.title.to_sym, c]}.flatten]
              
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

          def @verbiage.[]=(key, value)
            if self.has_key?(key)
              self[key].update_attributes({:content => value})
            else
              self.store(key, Verbiage.new( {:title => key.to_s, :content => value} ) )
              @contentable.content << self[key]
            end
  
            self
          end

          @verbiage
        end
        
      end
      
    end
  end
end

ActiveRecord::Base.send(:include, Blue::Acts::Contentable)
