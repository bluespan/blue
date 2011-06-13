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
      redirect_to :action => 'index'
    else
      render_default_template :new
    end
  end
  
  def edit
    @item = @model.find(params[:id])
    render_default_template
  end
  
  def update
    @item = @model.find(params[:id])
    if @item.update_attributes(model_params)
      flash[:notice] = "#{@item.class.name.titleize} <em>#{@item.title}</em> was successfully <em>updated.</em>"
      redirect_to :action => 'index'
    else
      render_default_template :edit
    end
  end
  
  def destroy
    @item = @model.destroy(params[:id])
    flash[:notice] = "#{@item.class.name.titleize} <em>#{@item.title}</em> was successfully <em>deleted.</em>"
    redirect_to :action => 'index'
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
    params[:controller].gsub(params[:prefix_path], "")
  end
  
  def model_params
    @model_params ||= params[@model.name.tableize.singularize.to_sym]
    @model_params
  end
  
  def item_name
    @model.class_name
  end
  
end