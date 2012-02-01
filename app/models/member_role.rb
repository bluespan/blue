class MemberRole < ActiveRecord::Base
  
  has_many :assigned_member_roles
  
  validates_uniqueness_of :name

end
