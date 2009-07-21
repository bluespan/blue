class Admin::NavigationsController < Admin::BlueAdminController
  
  before_filter :verify_editor  
  layout false
  
  def new
    @bucket = Navigation.new
    respond_to do |wants|
      wants.html
    end
  end
  
  def create
    @bucket = Navigation.new(params[:navigation])

    respond_to do |wants|
      if @bucket.save
        flash.now[:notice] = "Navigation Bucket <em>#{@bucket.title}</em> was successfully <em>created.</em>"
        wants.html { redirect_to :action => "index "}
        wants.js
      else
        wants.html { render :action => "new" }
        wants.js { render :template => "admin/error", :locals => {:object => @bucket} }
      end
    end
  end
  
  
  def edit
    @navigation = Navigation.find(params[:id])
    respond_to do |wants|
      wants.html
    end
  end
  
  def update
    @navigation = Navigation.find(params[:id])

    respond_to do |wants|
      if @navigation.update_attributes(params[:navigation])
        flash.now[:notice] = "#{@navigation.class.to_s.underscore.titleize} <em>#{@navigation.title}</em> was successfully <em>updated.</em>"
        wants.html { redirect_to :action => "index "}
        wants.js
      else
        wants.html { render :action => "edit" }
        wants.js
      end
    end
  end  
  
  def move
    @reference_navigation = Navigation.find(params[:reference_id])
    
    if (params[:type] == "page")
      @page = Page.find(params[:id])
      @navigation = Navigation.create({:page_id => params[:id]})
      flash.now[:notice] = "#{@navigation.page.display_name} <em>#{@navigation.page.title}</em> was successfully <em>added to the navigation.</em>"
    else
      @navigation = Navigation.find(params[:id])
      flash.now[:notice] = "#{@navigation.class.to_s.underscore.titleize} <em>#{@navigation.page.title}</em> was successfully <em>moved.</em>"
    end
    
    @moved = case params[:where]
      when "left"   : @navigation.move_to_left_of  @reference_navigation
      when "right"  : @navigation.move_to_right_of @reference_navigation
      when "child"  : @navigation.move_to_child_of @reference_navigation
    end
    
    if @moved
      respond_to do |wants|
        wants.js
      end
    end

  end
  
  def destroy  
    @navigation = Navigation.find(params[:id])
    @old_navigation_id = @navigation.id  
    @old_navigation = @navigation.clone
    respond_to do |wants|
      if @navigation.destroy
        flash.now[:notice] = "#{@old_navigation.page.display_name} <em>#{@old_navigation.page.title}</em> was successfully <em>removed from the navigation.</em>"
        wants.html { redirect_to :action => "index" }
        wants.js
      end
    end
  end
  
  private
  
  def verify_editor
    head :forbidden unless current_admin_user.has_role?(:editor)
  end
  
end
