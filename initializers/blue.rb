BLUE_TEMPLATE_ROOT = RAILS_ROOT+'/app/views/pages/templates/'
BLUE_ASSETS_ROOT = RAILS_ROOT+'/public/assets/'
BLUE_IMAGE_ASSETS_ROOT = BLUE_ASSETS_ROOT+'images/'

Page.types = [
  PageTypes::SubPage,
  PageTypes::HomePage,
  PageTypes::Link
]

module ActionView
  module Helpers
    module TextHelper
      module_function :pluralize, :truncate
    end
  end
end