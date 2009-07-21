class AdminUserRole < ActiveRecord::Base
  
  has_many :assigned_admin_user_roles
  has_many :admin_users, :through => :assigned_admin_user_roles
  
  validates_uniqueness_of :name
  
  def has_permission?(permission_name)
    has_attribute?(permission_name) && read_attribute(permission_name)
  end
end
