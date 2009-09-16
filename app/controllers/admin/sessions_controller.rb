class Admin::SessionsController < BlueController
  
  helper :all
  
  layout false
  
  def new
    @admin_session = AdminSession.new
  end

  def create
    @admin_session = AdminSession.new(params[:admin_session])
    if @admin_session.save
      redirect_to admin_pages_url
    else
      render :action => :new
    end
  end

  def destroy
    current_admin_user_session.destroy
    redirect_to new_admin_session_url
  end  
  
  
  def view_live_site
    session[:view_live_site] = params[:view_live_site] == "1" ? true : false
    render :nothing => true
  end
end
