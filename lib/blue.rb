# Blue
module Span
    
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
        
    module ApplicationController
      
      def self.included(base)
        base.send(:helper_method, :current_admin_user_session, :current_admin_user, 
                          :current_member, :current_member_session, :member_logged_in?, :new_member_session_url, 
                          :live_or_working, :current_engine)
      end

      protected  
        def current_admin_user_session
          return @current_admin_user_session if defined?(@current_admin_user_session)
          @current_admin_user_session = AdminSession.find
        end

        def current_admin_user
          return @current_admin_user if defined?(@current_admin_user)
          @current_admin_user = current_admin_user_session && current_admin_user_session.admin_user
        end

        def logged_in?
          not current_admin_user.nil?
        end

        def current_member_session
          return @current_member_session if defined?(@current_member_session)
          @current_member_session = MemberSession.find
        end

        def current_member
          return @current_member if defined?(@current_member)
          @current_member = current_member_session && current_member_session.member
        end

        def member_logged_in?
          not current_member.nil?
        end

        def new_member_session_url
          PageTypes::MemberSignInPage.find(:first).url
        end

        def live_or_working(page)
          ((not logged_in?) || session[:view_live_site]) && page ? page.live : page
        end
    end
    
    module Routing
      
      protected

      @@page_type_mappings ||= {}
 
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

class BlueError < StandardError #:nodoc:
end

class BlueTempateFileNotFound < BlueError #:nodoc:
end