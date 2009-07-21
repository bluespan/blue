class BlueController < ApplicationController
  unloadable
  
  helper_method :current_engine
  helper :all
  
  private
    def current_engine
      :blue
    end
end