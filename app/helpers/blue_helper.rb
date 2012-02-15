module BlueHelper

  def blue_features
    Span::Blue.features
  end
  
  def blue_collections
    Span::Blue.collections
  end
  
  def blue_error_messages_for (object)
    error_message = ""
    if object.errors.any?
      error_message += "<div class='errorExplanation'><h2>There were the following errors:</h2><ul>"
        object.errors.full_messages.each do |msg|
          error_message += "<li>#{msg}</li>"
        end 
      error_message += "</ul></div>"
    end
    error_message
  end

  def stylesheet_link_admin
    return unless logged_in?
    stylesheets = []
    Span::included_engines.each do |engine|
      Span::admin_stylesheets[engine.to_sym].each do |stylesheet|
        stylesheets << stylesheet_link_tag("#{engine.to_s.downcase}/admin/#{stylesheet}")
      end
    end
    Span::admin_stylesheets[:custom].each do |stylesheet|
      stylesheets << stylesheet_link_tag("/stylesheets/admin/#{stylesheet}")
    end
    stylesheets.join("\n\t")
  end

  def render_admin_toolbars
    html = ""
    Span::included_engines.each do |engine|
      html += render :partial => "admin/#{engine.to_s.downcase}_toolbar" if logged_in? and current_admin_user.can_access_engine?(engine)
    end
    return html
  end

  def current_admin_user_session
    return @current_admin_user_session if defined?(@current_admin_user_session)
    @current_admin_user_session = AdminSession.find
  end

  def current_admin_user=(user)
    @current_admin_user = user
  end

  def current_admin_user
    return @current_admin_user if defined?(@current_admin_user)
    @current_admin_user = current_admin_user_session && current_admin_user_session.admin_user
  end

  def logged_in?
    not current_admin_user.nil?
  end

  def current_member_session
    return @current_member_session if defined?(@current_member_session)
    @current_member_session = MemberSession.find
  end

  def current_member
    return @current_member if defined?(@current_member)
    @current_member = current_member_session && current_member_session.member
  end

  def member_logged_in?
    not current_member.nil?
  end

  def new_member_session_url
     (live_or_working PageTypes::MemberSignInPage.find(:first, :order => "created_at DESC")).url
  end

  def live_or_working(page = nil)
    version = ((not logged_in?) || session[:view_live_site]) ? :live : :working
    return version unless page
    page.version(version)
  end

  def humanize(string)
    string.to_s.underscore.titleize
  end
  
  def default_admin_url
    Span::included_engines.each do |engine|
      return self.send("admin_#{engine}_url") if current_admin_user.can_access_engine?(engine)
    end
  end
  

end