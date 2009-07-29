require File.dirname(__FILE__) + '/../test_helper'

class PagesControllerTest < ActionController::TestCase

  class PageTypes::NoTemplatePage < Page
    def template
      @template ||= TemplateFile.find('/no_template/none.html.erb')
    end
  end

  context "Page is requested" do
    setup do
      @home = PageTypes::HomePage.create!({:title => "home"}).publish
    end
    
    context "page doesn't exist" do
      should "render 404 page not found template" do
        get :show, :slug => "unknown_page"
        assert_template 'pages/404.html.erb'
      end
    end
    
    context "template doesn't exist" do
      setup do
        @page_with_no_template = PageTypes::NoTemplatePage.create({:title => "no-template"}).publish
      end
      
      should "render template not found error page" do
        get :show, :slug => "no-template"      
        assert_template 'errors/blue_template_file_not_found.html.erb'
      end
    end
    
    context "template does exist" do
      
      should "render template correct template" do
        get :show, :slug => "home"      
        assert_template 'pages/home_page/home.html.erb'
      end
    end
  end

end