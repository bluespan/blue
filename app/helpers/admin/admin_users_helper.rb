module Admin::AdminUsersHelper
  
  def roles
    conditions = []
    conditions = ["name != ?", "Blue Admin"]  unless current_admin_user.has_permission?(:blue_admin)
    
    @roles ||= AdminUserRole.find(:all, :conditions => conditions, :order => :name)
  end
  
end
