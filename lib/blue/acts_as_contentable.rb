require 'activerecord'

module Blue
  module Acts 
    module Contentable

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_contentable
          has_many :content, :as => :contentable, :dependent => :destroy
          include Juixe::Acts::Commentable::InstanceMethods
          extend Juixe::Acts::Commentable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods

        # This method is equivalent to obj.content.
        def find_comments_for(obj)
          contentable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
         
          Comment.find(:all,
            :conditions => ["contentable_id = ? and contentable_type = ?", obj.id, contentable],
            :order => "type, title"
          )
        end
      end
      
      # This module contains instance methods
      module InstanceMethods

      end
      
    end
  end
end

ActiveRecord::Base.send(:include, Blue::Acts::Contentable)
