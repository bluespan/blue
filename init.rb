# Include hook code here
require 'blue'

ActiveRecord::Base.send :include, Span::Blue::PageMethods
ActionController::Base.send :include, BlueHelper

config.after_initialize do
  Page.types ||= [ PageTypes::SubPage, PageTypes::HomePage, PageTypes::Link]
  Page.types = Page.types + [PageTypes::MemberSignInPage,  PageTypes::MemberSignOutPage]  if Span::Blue.features.include?(:membership)
end