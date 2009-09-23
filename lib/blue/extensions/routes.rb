if defined?(ActionController::Routing::RouteSet)
  class ActionController::Routing::RouteSet
    def load_routes_with_blue!
      lib_path = File.dirname(__FILE__)
      
      app_routes = File.expand_path(File.join(lib_path, *%w[.. .. .. .. .. .. config routes.rb]))
      blue_routes = File.expand_path(File.join(lib_path, *%w[.. .. .. .. blue config blue_routes.rb]))
      
      unless configuration_files.include?(blue_routes)
        if !configuration_files.include?(app_routes)
          configuration_files.unshift blue_routes
          configuration_files.unshift app_routes
        else
          configuration_files.push(blue_routes)
        end
      end
      
      load_routes_without_blue!
    end
 
    alias_method_chain :load_routes!, :blue
  end
end