# Include hook code here
require 'blue'

ActiveRecord::Base.send :include, Span::Blue::PageMethods
ActionController::Base.send :include, BlueHelper

config.to_prepare do
  Page.types ||= [ PageTypes::SubPage, PageTypes::HomePage, PageTypes::Link]
end