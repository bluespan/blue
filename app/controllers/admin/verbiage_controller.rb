class Admin::VerbiageController < Admin::BlueAdminController
  
  before_filter :verify_permission_to_admin_content, :default_wysiwyg_editor, :find_verbiage
  layout false
  
  helper :pages
  
  def edit
    render :template => "admin/verbiage/edit_#{params[:editor]}.html.erb"
  end
  
  def update
    @verbiage.update_attributes(params[:verbiage])
    
    respond_to do |wants|
      flash.now[:notice] = "#{@verbiage.class.to_s.underscore.titleize} <em>#{@verbiage.title}</em> was successfully <em>updated.</em>"
      wants.js
    end
  end
  
  private
  
  def verify_permission_to_admin_content
    head :forbidden unless current_admin_user.has_permission?(:admin_content)
  end
  
  def find_verbiage
    @verbiage = Verbiage.find(params[:id])
  end
  
  def default_wysiwyg_editor
    params[:editor] = "wymeditor" if params[:editor].nil?
  end
  
end
