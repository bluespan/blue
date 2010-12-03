class Admin::ContentPlacementsController < Admin::BlueAdminController
  
  before_filter :verify_editor, :init
  helper :pages
  
  layout false
  
  def edit
    @content_modules = ContentModule.find(:all)
  end
  
  def update
    @content_placement.update_attributes(params[:content_placement])
    
    respond_to do |wants|
      flash.now[:notice] = "Content Area <em>#{@content_placement.title}</em> was successfully <em>update.</em>"
      wants.js
    end
  end
  
  
  private
  
  def verify_editor
    head :forbidden unless current_admin_user.has_role?(:editor)
  end
  
  def init
   @page = Page.find(params[:page_id])
   @content_placement = ContentPlacement.find_by_page_id_and_title(@page.id, params[:id]) || ContentPlacement.create({:page_id => @page.id, :title => params[:id]})
  end
  
end
