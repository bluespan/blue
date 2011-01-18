class Admin::VerbiageController < Admin::BlueAdminController
  
  before_filter :verify_permission_to_admin_content, :find_verbiage
  layout false
  
  helper :pages
  
  def edit
    render :template => "admin/verbiage/edit_#{params[:editor]}.html.erb"
  end
  
  def update
    @verbiage.update_attributes(params[:verbiage])
    
    respond_to do |wants|
      language = ""
      if blue_features.include?(:localization)
    	  language = "<em>#{I18n.t(:"meta.language_name.en", :locale => current_locale, :default =>  current_locale)}</em> "
    	end
      flash.now[:notice] = "#{language}#{@verbiage.class.to_s.underscore.titleize} <em>#{@verbiage.title}</em> was successfully <em>updated.</em>"
      wants.js
    end
  end
  
  private
  
  def verify_permission_to_admin_content
    head :forbidden unless current_admin_user.has_permission?(:admin_content)
  end
  
  def find_verbiage
    @verbiage = Verbiage.find(params[:id])
    @page = @verbiage.contentable
    @page = @page.working if @page.published?
    
    @verbiage = @page.verbiage[@verbiage.title.to_sym][current_locale] || @page.verbiage.set_verbiage(@verbiage.title.to_sym, current_locale, params[:verbiage][:content])
  end
  
  def current_locale
    return params[:verbiage][:locale] if params[:verbiage] && params[:verbiage][:locale]
    I18n.locale.to_s
  end
  
end
