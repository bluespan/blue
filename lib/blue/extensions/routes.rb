if defined?(ActionController::Routing::RouteSet)
  class ActionController::Routing::RouteSet
    def load_routes_with_blue!
      lib_path = File.dirname(__FILE__)
      blue_routes = File.join(lib_path, *%w[.. .. .. config blue_routes.rb])
      
      unless configuration_files.include?(blue_routes)
        configuration_files << blue_routes
      end
          
      load_routes_without_blue!
    end
 
    alias_method_chain :load_routes!, :blue
  end
end