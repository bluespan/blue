class Admin::PagesController < Admin::BlueAdminController
  layout "admin", :only => :index
  before_filter :verify_publisher, :only => [:publish, :publish_all]
  before_filter :verify_permission_to_admin_content, :only => [:new, :edit, :create, :update, :destroy]
  before_filter :find_model, :except => [:index, :publish_all]
  
  def index
    @pages = Page.working.find(:all, :order => :title)
    respond_to do |wants|
      wants.html
      wants.json { render :json => @pages }
    end
  end
  
  def new
    respond_to do |wants|
      wants.html
      wants.json { @page.to_json }
    end
  end
  
  def edit
    respond_to do |wants|
      wants.html
      wants.json { @page.to_json }
    end
  end
 
  def create
    respond_to do |wants|
      if @page.save 
        #ActivityLog.log(current_admin_user, @page, :created, "#{current_admin_user.fullname} created #{@page.class.to_s} #{@page.title}")
      
        flash.now[:notice] = "#{@page.display_name} <em>#{@page.title}</em> was successfully <em>created.</em>"
        wants.html { redirect_to :action => "index "}
        wants.js
      else
        wants.html { render :action => "new" }
        wants.js { render :template => "admin/error", :locals => {:object => @page} }
      end
    end
  end
  
  def update
    respond_to do |wants|
      if @page.update_attributes(params[:page])
        #ActivityLog.log(current_admin_user, @page, :updated, "#{current_admin_user.fullname} updated #{@page.class.to_s} #{@page.title}")
        
        flash.now[:notice] = "#{@page.display_name} <em>#{@page.title}</em> was successfully <em>updated.</em>"
        wants.html { redirect_to :action => "index "}
        wants.js
      else
        wants.html { render :action => "edit" }
        wants.js { render :template => "admin/error", :locals => {:object => @page} }
      end
    end
  end
  
  def destroy  
    @old_page_id = @page.id  
    @old_page = @page.clone
    @old_navigations = @page.navigations
    respond_to do |wants|
      if @page.destroy
        #ActivityLog.log(current_admin_user, @old_page, :deleted, "#{current_admin_user.fullname} deleted #{@old_page.class.to_s} #{@old_page.title}")
        
        flash.now[:notice] = "#{@page.display_name} <em>#{@old_page.title}</em> was successfully <em>deleted.</em>"
        wants.html { redirect_to :action => "index" }
        wants.js { render :template => "admin/pages/destroy.js" }
      end
    end
  end
  
  def publish
    respond_to do |wants|
      if published_page = @page.publish
        #ActivityLog.log(current_admin_user, published_page, :published, "#{current_admin_user.fullname} published #{published_page.class.to_s} #{published_page.title}")
        flash.now[:notice] = "#{@page.display_name} <em>#{@page.title}</em> was successfully <em>published.</em>"
        wants.html { redirect_to admin_publish_url }
        wants.js { render :template => "admin/publish/page.js" }
      end
    end
  end
  
  def publish_all
    respond_to do |wants|
      if published_pages = Page.publish_all
        #Page.rebuild_index
        published_pages.each do |published_page|
          ActivityLog.log(current_admin_user, published_page, :published, "#{current_admin_user.fullname} published #{published_page.class.to_s} #{published_page.title}")
        end
        
        flash.now[:notice] = "<em>All</em> Pages were successfully <em>published.</em>"
        wants.html { redirect_to admin_publish_url }
        wants.js { render :template => "admin/publish/page_all.js" }
      end
    end
  end
  
  
  private
  
  def verify_publisher
    head :forbidden unless current_admin_user.has_permission?(:publish)
  end
  
  def verify_permission_to_admin_content
    head :forbidden unless current_admin_user.has_permission?(:admin_content)
  end
  
  def find_model
    if params[:page] && params[:page][:type]
      page_type = params[:page][:type]
      type = page_type.split("::")[1]
      params[:page].delete(:type)
      page_class = Module.const_get("PageTypes").const_get(type)
    else
      page_class = Page
    end
    
    if params[:id]
      @page = Page.find(params[:id])
      
      if params[:page]
        @page.send(:attributes=, params[:page], false)
        @page.class_type = page_type
      end
    else
      @page = page_class.new(params[:page])
    end
  end
end
