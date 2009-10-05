require File.dirname(__FILE__) + '/../../test_helper'

class Admin::VerbiageControllerTest < ActionController::TestCase

  tests Admin::VerbiageController

  context "As a logged editor" do
    setup do
      # Log in as admin
      @controller.expects(:require_admin_session).returns(true)
      
      @home_page = PageTypes::HomePage.create(:title => "home")
      @home_page.verbiage[:main] = "This is my default verbiage"
      
      @controller.current_admin_user = Factory.build(:editor_user)
    end
    
    context "edit" do
      setup do
        get :edit, :id => @home_page.verbiage[:main].id
      end
      
      should_respond_with :success 
      should_render_template :edit 
      
      should "have the verbiage id in the form action" do
        assert_select "form[action=?]", /.+\/#{@home_page.verbiage[:main].id}$/
      end
    end
    
    context "update" do
      setup do
        post :update, :format => "js", :id => @home_page.verbiage[:main].id, :verbiage => { :content => "This is my new verbiage" } 
      end
      
      should_respond_with :success    
      
      should("update verbiage") do  
        assert_equal "This is my new verbiage", Page.find(@home_page.id).verbiage[:main].content
      end
    end
  
  end
   
end