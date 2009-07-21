module Admin::AdminUsersHelper
  
  def roles
    @roles ||= AdminUserRole.find(:all, :order => :name)
  end
  
end
