class Admin::GlobalVerbiageController < Admin::BlueAdminController
  
  before_filter :verify_editor
  layout false
  
  helper :pages
  
  def edit
    @verbiage = GlobalVerbiage.find(params[:id])
  end
  
  def update
    @verbiage = GlobalVerbiage.find(params[:id])
    @verbiage.update_attributes({:content => params[:global_verbiage][:content]})
    
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
