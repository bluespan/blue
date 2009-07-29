# modified by blue

Page.types = [
  PageTypes::SubPage,
  PageTypes::HomePage,
  PageTypes::Link
]

BLUE_TEMPLATE_ROOT = RAILS_ROOT+'/app/views/pages'
BLUE_ASSETS_ROOT = RAILS_ROOT+'/public/assets/'
BLUE_IMAGE_ASSETS_ROOT = BLUE_ASSETS_ROOT+'images/'

module ActionView
  module Helpers
    module TextHelper
      module_function :pluralize, :truncate
    end
  end
end

ActiveSupport::Inflector.inflections do |inflect| 
  inflect.uncountable %w( content ) 
end 
