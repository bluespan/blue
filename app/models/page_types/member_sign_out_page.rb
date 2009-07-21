class PageTypes::MemberSignOutPage < Page
  
  configure_blue_page do |page| 
    page.type_name = "Member Sign Out Page"
  end
  
  def template
    false
  end
  
  def link
    '/member_session/signout'
  end
  
  def members_only?
    true
  end
  
end