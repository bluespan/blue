class Admin::AssetsController < Admin::BlueAdminController
  layout "assets", :only => [:viewer, :show]
  
  before_filter :verify_editor, :only => [:new, :new_folder, :create, :create_folder]
  after_filter :close_assets, :except => :create
  
  def index
    redirect_to :action => :viewer
  end
  
  def new
    @path = request.referrer.gsub(/^.+viewer\/?/, "").gsub("%20", " ")
  end
  
  def new_folder
    @path = request.referrer.gsub(/^.+viewer\/?/, "").gsub("%20", " ")
  end
  
  def create
    if params[:asset][:file]
      @asset = File.open(BLUE_ASSETS_ROOT + params[:asset][:path] + "/" + params[:asset][:file].original_filename, "w", :encoding => "BINARY") { |f| f.write(params[:asset][:file].read) }
    
      
      flash.now[:notice] = "Asset <em>#{params[:asset][:file].original_filename}</em> was successfully <em>uploaded.</em>"
      render :nothing => true
      
    end
  end
  
  def create_folder
    if params[:folder][:name]
      params[:folder][:name] = params[:folder][:name].gsub(".", "").gsub("~", "")
      
      Dir.mkdir(BLUE_ASSETS_ROOT + params[:folder][:path] + "/" + params[:folder][:name] )
      
      flash.now[:notice] = "Folder <em>#{params[:folder][:name]}</em> was successfully <em>created.</em>"
      render :nothing => true
    end
  end
  
  
  def viewer
    @assets = Asset.find(:all, :dir => BLUE_ASSETS_ROOT + (params[:path] || ""))

    respond_to do |wants|
      wants.html
      wants.json { render :json => @assets }
    end
  end
  
  def link

  end
  
  def selector
    @assets = Asset.find(:all, :dir => BLUE_ASSETS_ROOT + (params[:path] || ""))
    render :layout => false
  end
  
  def show
    @asset = Asset.find(params[:path], :dir => BLUE_ASSETS_ROOT)
    respond_to do |wants|
      wants.html
      wants.json { render :json => @asset }
    end
  end
  
  def destroy
    @asset = Asset.find(params[:path], :dir => BLUE_ASSETS_ROOT)
    @asset.destroy
    
    flash.now[:notice] = "Asset <em>#{params[:path]}</em> was successfully <em>deleted.</em>"
    respond_to do |wants|
      wants.html { redirect_to :action => "index "}
      wants.js
    end
  rescue => e
    respond_to do |wants|
      flash.now[:error] = "Asset <em>#{params[:path]}</em> was failed to <em>deleted.</em> #{e}"
      wants.js { render :template => "admin/error", :locals => {:object => @page} }
    end
  end
  
  private

  def verify_editor
    head :forbidden unless current_admin_user.has_role?(:editor)
  end

  
  def close_assets
    @assets.collect { |asset| asset.close } if @assets
    @asset.close if @asset
  end
  
end
