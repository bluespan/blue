class Admin::ContentModulesController < Admin::BlueAdminController
  
  before_filter :verify_editor, :default_wysiwyg_editor
  layout "admin", :only => :index
  
  helper :pages
  
  def index
    @content_modules = ContentModule.find(:all)
  end
  
  def new
    @content_module = ContentModule.new
  end
  
  def create
    @content_module = ContentModule.new(params[:content_module])
    
    if @content_module.save
      respond_to do |wants|
        flash.now[:notice] = "#{@content_module.class.to_s.underscore.titleize} <em>#{@content_module.title}</em> was successfully <em>updated.</em>"
        wants.js
      end
    else
      respond_to do |wants|
        wants.js { render :template => "admin/error", :locals => {:object => @content_module} }
      end
    end
  end
  
  def edit
    @content_module = ContentModule.find(params[:id])
    render :template => "admin/content_modules/edit.html.erb"
  end
  
  def update
    @content_module = ContentModule.find(params[:id])
    @content_module.update_attributes(params[:content_module])
    
    respond_to do |wants|
      flash.now[:notice] = "#{@content_module.class.to_s.underscore.titleize} <em>#{@content_module.title}</em> was successfully <em>updated.</em>"
      wants.js
    end
  end
  
  def destroy  
    @content_module = ContentModule.find(params[:id])
    respond_to do |wants|
      if @content_module.destroy
        #ActivityLog.log(current_admin_user, @old_page, :deleted, "#{current_admin_user.fullname} deleted #{@old_page.class.to_s} #{@old_page.title}")
        
        flash.now[:notice] = "#{@content_module.class.to_s.underscore.titleize} <em>#{@content_module.title}</em> was successfully <em>deleted.</em>"
        wants.html { redirect_to :action => "index" }
        wants.js
      end
    end
  end
  
  private
  
  def verify_editor
    head :forbidden unless current_admin_user.has_role?(:editor)
  end
  
  def default_wysiwyg_editor
    params[:editor] = "wymeditor" if params[:editor].nil?
  end
  
end
