class Admin::MembershipController < Admin::BlueAdminController
  
  before_filter :check_permissions, :create_or_load_member
  
  def show
    render :action => :edit
  end
  
  def edit
  end
  
  def update
    if @member.update_attributes(params[:member])
      flash.now[:notice] = "Membership login successfully updated."
    end
    render :action => :edit
  end
  
  private
  def create_or_load_member
    unless @member = Member.find(:first)
      #@member = Member.create({:login => "member", :password => "member", :password_confirmation => "member"})
    end
  end
  
  def check_permissions
    redirect_to "/admin" unless current_admin_user.has_permission?(:admin_membership)
  end
  
end
