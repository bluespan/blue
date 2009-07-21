# Blue
module Span
    
  module Blue
    
    module Routing
      
      protected

      def Routing.included(mod)
        @@page_type_mappings ||= {}
      end
      
      def Routing.map_page_type_route(page_type, function)
        @@page_type_mappings[page_type.to_s] = function
      end
      
      def route
        send(@@page_type_mappings[@page.class.to_s]) if @@page_type_mappings.has_key?(@page.class.to_s)
      end
      
      def load_page(slug, ancestors)
        if @page = Page.working(slug)

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
        if @page.nil? == false && @page.members_only? && member_logged_in? == false && logged_in? == false
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

module Blue
  include Span::Blue  
end