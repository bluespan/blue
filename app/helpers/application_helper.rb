# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def logged_in?
    not current_admin_user.nil?
  end
  
  def humanize(string)
    string.to_s.underscore.titleize
  end
end
