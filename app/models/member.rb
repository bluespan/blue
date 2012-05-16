class Member < ActiveRecord::Base
  acts_as_authentic :session_class => "MemberSession"
  
  has_assigned_member_roles
  
  def name
  	if attributes.include?("name")
  		return attributes["name"]
  	else
    	return "#{firstname} #{lastname}"
    end
  end
  
end
