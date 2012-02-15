class Admin::AdminUsersController < Admin::BlueAdminController
  
  layout "admin", :only => :index
  
  before_filter :find_model, :except => :index
  before_filter :verify_administrator, :except => :index
  
  def index
    @admin_users = AdminUser.find(:all)
  end
  
  def new
  end

  def create
    respond_to do |wants|
       if @admin_user.save(params[:admin_user])
         flash.now[:notice] = "#{@admin_user.class.to_s.underscore.titleize} <em>#{@admin_user.fullname}</em> was successfully <em>created.</em>"
            logger.info "SUCCESS"
         wants.html { render :partial => "admin_user", :locals => {:admin_user => @admin_user} }
         wants.js
       else
         logger.info "ERROR"
         wants.html { render :action => :new }
         wants.js { render :template => "admin/error", :locals => {:object => @admin_user} }
       end
     end
  end

  def show
    @admin_user = @current_admin_user
  end

  def edit
  end

  def update
    respond_to do |wants|
       if @admin_user.update_attributes(params[:admin_user])
         flash.now[:notice] = "#{@admin_user.class.to_s.underscore.titleize} <em>#{@admin_user.fullname}</em> was successfully <em>updated.</em>"
         wants.html { render :partial => "admin_user", :locals => {:admin_user => @admin_user} }
         wants.js
       else
         wants.html { render :action => :edit }
         wants.js { render :template => "admin/error", :locals => {:object => @admin_user} }
       end
     end
  end
  
  def destroy
    @old_admin_user = @admin_user.clone
    respond_to do |wants|
       if @admin_user.destroy
         flash.now[:notice] = "#{@old_admin_user.class.to_s.underscore.titleize} <em>#{@old_admin_user.fullname}</em> was successfully <em>deleted.</em>"
         wants.html { redirect_to :action => "index "}
         wants.js
       else
         wants.html { render :action => :index }
         wants.js { render :template => "admin/error", :locals => {:object => @old_admin_user} }
       end
     end
  end
  
  protected 
  
  def find_model
    params[:admin_user][:admin_user_roles] = AdminUserRole.find(:all, :conditions => {:name => params[:admin_user][:admin_user_roles].keys} ) if params[:admin_user] && params[:admin_user][:admin_user_roles]
    @admin_user = params[:id] ? AdminUser.find(params[:id]) : AdminUser.new(params[:admin_user])
  end
  
  def verify_administrator
    head(422) unless current_admin_user.has_permission?(:admin_admin_users) || ((action_name == 'edit' || action_name == 'update') && params[:id] == current_admin_user.id.to_s)
  end
  
end
