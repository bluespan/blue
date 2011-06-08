# Blue

require 'blue/extensions/routes'
require 'blue/acts_as_contentable'
require 'blue/acts_as_collection'
require 'blue/has_localized_data'
require 'blue/blue_form_builder'

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

module Span
  
  @@included_engines = ["blue"]
  @@admin_stylesheets = {}
  mattr_accessor :included_engines, :admin_stylesheets 
  
  module RenderAnywhere

      class DummyController
          def logger
              RAILS_DEFAULT_LOGGER
          end
          def headers
              {}
          end
      end

      def render(options, assigns = {})
          viewer = ActionView::Base.new(ActionController::Base.view_paths, assigns, DummyController.new)
          viewer.render options
      end

      def template_exists?(path, assigns = {})
          viewer = ActionView::Base.new(ActionController::Base.view_paths, assigns, DummyController.new)
          viewer.pick_template_extension(path) rescue false
      end
  end  
    
  module Blue
    
    Span::admin_stylesheets[:custom] = []
    Span::admin_stylesheets[:blue] = ["blue_dialog", "content", "jquery.jgrowl.css", "shared"]
    
    @@features = []
    mattr_accessor :features
    @@collections = []
    mattr_accessor :collections
    @@locales = ['en']
    mattr_accessor :locales
    
    
    def @@features.method_missing(method)
      has_key?(method)
    end
    
    module Routing
      
      protected
      
      mattr_accessor :page_type_mappings
      @@page_type_mappings ||= {}
     
 
      module ClassMethods
        def map_page_type_route(page_type, function)
          Span::Blue::Routing.page_type_mappings[page_type.to_s] = function
        end
      
      end
      

      def route
        send(Span::Blue::Routing.page_type_mappings[@page.class.to_s]) if Span::Blue::Routing.page_type_mappings.has_key?(@page.class.to_s)
      end
      
      def load_page(slug, ancestors, leaf)
        if @page = Page.load_from_url(slug, ancestors)

          # Show the live version if not logged in
          @page = live_or_working @page
  
          unless @page.nil?
            # Is the url valid?
            path = "#{ancestors}/#{slug}"
            path = "/#{path}" unless path[0,1] == "/"
            
            @navigation = @page.navigation(path)
            @page = nil if @navigation.blank? && (not ancestors.blank?)
          end
          
        end

        # Require member log in?
       
        if leaf == true && @page.nil? == false && @page.members_only? && member_logged_in? == false && logged_in? == false
          session[:member_requested_page] = request.path
          redirect_to new_member_session_url
        else  
          return @page
        end
      end
      
    end
    
    module PageMethods
      def self.included(base)
        base.extend ClassMethods
      end
      
      module ClassMethods
        def configure_blue_page
          cattr_accessor :type_name
        
          include Span::Blue::PageMethods::InstanceMethods
          extend  Span::Blue::PageMethods::SingletonMethods
          
          yield self
        end
      end
      
      module SingletonMethods
      end

      module InstanceMethods
      end
      
    end
    
  end
end

class BlueError < StandardError #:nodoc:
end

class BlueTempateFileNotFound < BlueError #:nodoc:
end