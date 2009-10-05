require File.dirname(__FILE__) + '/../../test_helper'


class Admin::PagesControllerTest < ActionController::TestCase
 
  tests Admin::PagesController

  context "Home page" do
    
    setup do
      # Log in as admin
      @controller.expects(:require_admin_session).returns(true)

      @controller.current_admin_user = Factory.build(:editor_user)
    end
    
    context "on create" do

      setup do
        post :create, :format => "js", :page => { :type => "PageTypes::HomePage", :template_file => "home.html.erb", :title => "My Home Page" }
      end
      
      should_respond_with :success      
    end
  
  end
  
  private 

 
end