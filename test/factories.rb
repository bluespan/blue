Factory.define :editor, :class => AdminUser do |u|
  u.first_name 'Admin'
  u.last_name  'User'
  u.has_permssion?(:admin_content) true
end
