class Member < ActiveRecord::Base
  acts_as_authentic :session_class => "MemberSession"
  
  has_assigned_member_roles
end
