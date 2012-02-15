class Admin::BlueAdminController < BlueController
  layout "admin"
  before_filter :require_admin_session
  
  def index
    redirect_to default_admin_url
  end
  
  private
  
  def require_admin_session
    redirect_to new_admin_session_url if current_admin_user.nil?
  end
  
end