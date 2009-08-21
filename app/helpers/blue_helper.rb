module BlueHelper
  def logged_in?
    not current_admin_user.nil?
  end

  def humanize(string)
    string.to_s.underscore.titleize
  end
end