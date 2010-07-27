module Admin::AdminUsersHelper
  
  def roles
    conditions = []
    conditions = ["name != ?", "Blue Admin"]  unless current_admin_user.has_permission?(:blue_admin)
    
    @roles ||= AdminUserRole.find(:all, :conditions => conditions, :order => :name).delete_if do |role|
      role.name == "Commentator" && Span::Blue.features.include?(:comments) == false
    end
  end
  
end
