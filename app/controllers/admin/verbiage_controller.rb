class Admin::VerbiageController < Admin::BlueAdminController
  
  before_filter :verify_editor
  layout false
  
  def edit
    @page = Page.working.find(params[:page_id])
    @verbiage = @page.verbiage(params[:id])
  end
  
  def update
    @page = Page.working.find(params[:page_id])
    @verbiage = @page.verbiage(params[:id], :value => params[:verbiage][:content])
    
    respond_to do |wants|
      flash.now[:notice] = "#{@verbiage.class.to_s.underscore.titleize} <em>#{@verbiage.title}</em> was successfully <em>updated.</em>"
      wants.js
    end
  end
  
  private
  
  def verify_editor
    head :forbidden unless current_admin_user.has_role?(:editor)
  end
  
end
