class PageTypes::MemberSignInPage < Page
  
  configure_blue_page do |page| 
    page.type_name = "Member Sign In Page"
  end
  
  def template
    @template ||= TemplateFile.find('/member_sign_in_page/member_sign_in.html.erb')
  end
  
  def members_only?
    false
  end
  
end