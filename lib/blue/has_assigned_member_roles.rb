require 'activerecord'

module Blue
  module Has 
    module AssignedMemberRoles

      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        def has_assigned_member_roles
          has_many :assigned_member_roles, :as => :assignable, :dependent => :destroy
          has_many :member_roles, :through => :assigned_member_roles
                    
          include Blue::Has::AssignedMemberRoles::InstanceMethods
        end
        
      end
      
      module InstanceMethods
        
        def has_role?(role_name)
          member_roles.map { |role| role.name.downcase }.include?(role_name.to_s.downcase)
        end
        
        def can_access? (member)
          return true if member_roles.count == 0
          member_roles.each do |role|
            return true if member.has_role?(role.name)
          end
          false
        end

      end      

    end
  end
end



ActiveRecord::Base.send(:include, Blue::Has::AssignedMemberRoles)