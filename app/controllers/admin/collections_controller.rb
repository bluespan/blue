class Admin::CollectionsController < Admin::BlueAdminController
  helper :pages
  before_filter :determine_model, :add_default_view_path
  
  def index
    @items = @model.find(:all)
    render_default_template
  end

  def new
    @item = @model.new
    render_default_template
  end
  
  def create
    @item = @model.new(model_params)
    if @item.save
      flash[:notice] = "#{@item.class.name.titleize} <em>#{@item.title}</em> was successfully <em>created.</em>"
      @redirect_to ||= {:action => 'index'}
      redirect_to @redirect_to.is_a?(Proc) ? @redirect_to.call : @redirect_to 
    else
      render_default_template :new
    end
  end
  
  def edit
    @item = @model.find(params[:id])
    render_default_template
  end
  
  def update
   respond_to do |wants|
      @item = @model.find(params[:id])
      if @item.update_attributes(model_params)
        #ActivityLog.log(current_admin_user, @page, :updated, "#{current_admin_user.fullname} updated #{@page.class.to_s} #{@page.title}")

        flash.now[:notice] = "#{@item.class.name.titleize} <em>#{@item.display_title}</em> was successfully <em>updated.</em>"
        wants.html do
          @redirect_to ||= {:action => 'index'}
          redirect_to @redirect_to.is_a?(Proc) ? @redirect_to.call : @redirect_to 
        end
        wants.js
      else
        wants.html { render_default_template :edit }
        wants.js { render :template => "admin/error", :locals => {:object => @item} }
      end
    end
  end
  
  def destroy
    @item = @model.destroy(params[:id])
    flash[:notice] = "#{@item.class.name.titleize} <em>#{@item.display_title}</em> was successfully <em>deleted.</em>"
    @redirect_to ||= {:action => 'index'}
    redirect_to @redirect_to.is_a?(Proc) ? @redirect_to.call : @redirect_to 
  end
  
  private
  
  def render_default_template(action = nil)
    render :file => "#{action || params[:action]}", :layout => 'admin'
  end
  
  def add_default_view_path
    prepend_view_path ["#{RAILS_ROOT}/vendor/plugins/blue/app/views/admin/collections/"]
    prepend_view_path ["#{RAILS_ROOT}/app/views/#{params[:controller]}"]
  end
  
  def determine_model
    @model ||= controller_unnamespaced.gsub(/^.*\//, "").tableize.classify.constantize if params[:controller]
    raise "Can't detemine the collection model" if @model.nil?
  end
  
  def controller_unnamespaced
    params[:controller].gsub(params[:prefix_path] || "", "")
  end
  
  def model_params
    @model_params ||= params[item_name.tableize.singularize.to_sym]
    @model_params
  end
  
  def item_name
    @model.class_name
  end
  
end