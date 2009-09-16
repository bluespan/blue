class AdminUser < ActiveRecord::Base
  acts_as_authentic :session_class => "AdminSession"
  
  has_attached_file :photo, :styles => { :thumb => "64x64#", :icon => "32x32#" }, 
                            :default_style => :thumb, :default_url => "/images/blue/default_admin_user/:style.jpg",
                            :path => ":rails_root/public/assets/:class/:attachment/:id/:style_:basename.:extension",
                            :url => "/assets/:class/:attachment/:id/:style_:basename.:extension"
  
  has_many :assigned_admin_user_roles
  has_many :admin_user_roles, :through => :assigned_admin_user_roles
  has_many :comments
  
  validates_presence_of :firstname, :lastname
    
  def fullname
    "#{firstname} #{lastname}"
  end
  
  def roles
    admin_user_roles
  end
  
  def has_role?(role_name)
    roles.map { |role| role.name.downcase }.include?(role_name.to_s.downcase)
  end
  
  def has_permission?(permission_name)
    roles.map { |role| role.has_permission?(permission_name) }.include?(true)
  end
end
