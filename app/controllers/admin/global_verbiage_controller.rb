class Admin::GlobalVerbiageController < Admin::BlueAdminController
  
  before_filter :verify_editor, :find_verbiage
  layout false
  
  helper :pages
  
  def edit
    render :template => "admin/global_verbiage/edit_#{params[:editor]}.html.erb"
  end
  
  def update
    @verbiage.update_attributes({:content => params[:verbiage][:content]})
    
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
  
  def find_verbiage
     @verbiage = GlobalVerbiage.find(params[:id])
     
     if blue_features.include?(:localization) and @verbiage.locale != current_locale
        @verbiage = GlobalVerbiage.get(@verbiage.title.to_sym, current_locale)
     end
   end
  
  def verify_editor
    head :forbidden unless current_admin_user.has_role?(:editor)
  end
  
  def current_locale
    return params[:verbiage][:locale] if params[:verbiage] && params[:verbiage][:locale]
    I18n.locale.to_s
  end
  
end
