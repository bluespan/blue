require File.dirname(__FILE__) + '/../test_helper'


class PagesControllerTest < ActionController::TestCase

  tests PagesController

  class PageTypes::NoTemplatePage < Page
    def template
      @template ||= TemplateFile.find('/no_template/none.html.erb')
    end
  end

  context "Published Home Page is requested" do
    setup do
      @home = PageTypes::HomePage.create({:title => "home", :slug => "home"}).publish
      @request.set_REQUEST_URI "/home"
      get :show
    end
    
    should "render the home page template" do
      assert_template 'pages/home_page/home.html.erb'
    end
  end
    
    context "template doesn't exist" do
      setup do
        @page_with_no_template = PageTypes::NoTemplatePage.create({:title => "no-template"}).publish
        @request.set_REQUEST_URI "/no-template"
        get :show
      end
      
      should "render template not found error page" do  
        assert_template 'errors/blue_template_file_not_found.html.erb'
      end
    end

  
  context "Unpublished Page is reqeusted" do
    
    setup do
      @home = PageTypes::HomePage.create({:title => "home"})
      @request.set_REQUEST_URI "/home"
      get :show
    end

    should "render 404 page not found template" do
      assert_template 'pages/404.html.erb'
    end
        
  end

end