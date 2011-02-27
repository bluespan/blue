# Include hook code here
require 'blue'

ActiveRecord::Base.send :include, Span::Blue::PageMethods
ActionController::Base.send :include, BlueHelper

config.after_initialize do
  Page.types ||= [ PageTypes::SubPage, PageTypes::HomePage, PageTypes::Link]
  Page.types = Page.types + [PageTypes::MemberSignInPage,  PageTypes::MemberSignOutPage]  if Span::Blue.features.include?(:membership)
  
  
  # if Span::Blue.features.include?(:collections)
  #   Span::Blue.collections.each do |collection|
  #     ActionController::Routing::Routes.draw do |map|
  #       map.namespace :admin do |admin|
  #   
  #         admin.namespace :collections do |collections| 
  #           collections.resources collection
  #         end
  #       end
  #     end
  #   end
  #   ActionController::Routing::Routes.reload
  # end
end