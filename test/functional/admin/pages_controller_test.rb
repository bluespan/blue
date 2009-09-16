require File.dirname(__FILE__) + '/../../test_helper'


class Admin::PagesControllerTest < ActionController::TestCase

  context "Video page" do
    
    setup do
      # Log in as admin
      @controller.expects(:require_admin_session).returns(true)
      @controller.expects(:verify_editor).returns(true)
    end
    
    context "on create" do

      
      setup do
        current_admin_user = stub("admin_user", :has_role? => true)
        @controller.stubs(:current_admin_user).returns(current_admin_user)
        post :create, :format => "js", :page => { :type => "PageTypes::VideoPage", :template_file => "video.html.erb", :title => "My Video Page", :video_lookup => "vimeo_2029334" }
      end
      
      
      should_respond_with :success
      
    end
  
  end
  
  private 

 
end