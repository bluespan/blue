class BlueController < ApplicationController
  unloadable
  
  filter_parameter_logging :password
  
  helper_method :current_engine
  helper :all
  
  private
    def current_engine
      :blue
    end
end