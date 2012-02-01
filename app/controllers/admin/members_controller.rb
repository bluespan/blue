class Admin::MembersController < Admin::BlueAdminController
  
  before_filter :check_permissions
  
  layout false
  
  def new
    @member = Member.new
  end
  
  def create
    # Generate random password
    password_chars = ("a".."z").to_a + ("1".."9").to_a 
    password = Array.new(8, '').collect{password_chars[rand(password_chars.size)]}.join
    
    params[:member] = {:login => params[:member][:email], :password => password, :password_confirmation => password}.merge(params[:member])
    @member = Member.new(params[:member])
    
    respond_to do |wants|
      if @member.save
        flash.now[:notice] = "Member <em>#{@member.name}</em> successfully created."
        wants.html { redirect_to admin_membership_url}
        wants.js
      else
        wants.html { render :action => "new" }
        wants.js { render :template => "admin/error", :locals => {:object => @member} }
      end
    end
  end
  
  def edit
    @member = Member.find(params[:id])
  end
  
  def update
    @member = Member.find(params[:id])
    
    respond_to do |wants|
      if @member.update_attributes(params[:member])
        flash.now[:notice] = "Member <em>#{@member.name}</em> successfully updated."
        wants.html { redirect_to admin_membership_url }
        wants.js
      else
        wants.html { render :action => "edit" }
        wants.js { render :template => "admin/error", :locals => {:object => @member} }
      end
    end
  end
  
  def destroy
    @member = Member.find(params[:id])
    respond_to do |wants|
      if @member.destroy
        #ActivityLog.log(current_admin_user, @old_page, :deleted, "#{current_admin_user.fullname} deleted #{@old_page.class.to_s} #{@old_page.title}")
        
          flash.now[:notice] = "Member <em>#{@member.name}</em> successfully deleted."
          wants.html { redirect_to admin_membership_url }
          wants.js { render :template => "admin/members/destroy.js" }
      end
    end
  end
  
  private
  def check_permissions
    redirect_to "/admin" unless current_admin_user.has_permission?(:admin_membership)
  end
  
end
