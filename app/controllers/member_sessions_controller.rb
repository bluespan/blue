class MemberSessionsController < BlueController

  before_filter :load_page

  def new
    @member_session = MemberSession.new
    render :template => "pages/templates/#{@page.template.name}"
  end

  def create
    @member_session = MemberSession.new(params[:member_session])
    if @member_session.save
      flash[:notice] = "You have successfully signed in."
     
      member_requested_page = redirect_after_login

      session[:member_requested_page] = nil
      redirect_to member_requested_page
    else
      flash[:error] = "Sign in was unsuccessful, please try again."
      redirect_to new_member_session_url
    end
  end
  
  def signout
    current_member_session.destroy
    flash[:notice] = "You have successfully signed out."
    redirect_to new_member_session_url
  end

  def destroy
    current_member_session.destroy
    redirect_to new_member_session_url
  end  
  
  private

  def redirect_after_login
    session[:member_requested_page] || request.referer
  end

  def load_page
      @page = live_or_working PageTypes::MemberSignInPage.find(:first, :order => "created_at DESC")

      if @page
        @navigation = @page.navigation(@page.url)
      else
        render :status => 404, :template => "pages/404.html.erb"
      end
    end

end
