require File.dirname(__FILE__) + '/../test_helper'

class PagesHelperTest < ActionView::TestCase
  
  context "Verbiage" do
    setup do
      @page = PageTypes::HomePage.create(:title => "home")
    end
    
    context "Not Logged In" do
      setup do
        self.stubs(:logged_in?).returns(false)
      end
    
      context "Create default verbiage" do
        setup do
          output_buffer = ""
          verbiage(:main) {"this is my default content"} 
        end
        
        should_change("the number of content", :by => 1) { Content.count }
        should "render default content" do
          assert_dom_equal "this is my default content", output_buffer
        end
      end
     
      context "Create default verbiage only the first time" do
        setup do
          output_buffer = ""
          verbiage(:main, :contentable => @page) {"this is my default content"} 
          page = Page.find(@page.id)
          verbiage(:main, :contentable => page) {"new default content"} 
        end
        
        should_change("the number of content", :by => 1) { Content.count }
        should "render default content" do
          assert_dom_equal "this is my default contentthis is my default content", output_buffer
        end
      end
     
      
    end
    
    context "Admin Logged In" do
      setup do
        self.stubs(:logged_in?).returns(true)
        self.expects(:render).with { |params| params[:partial] == "admin/verbiage/verbiage" && params.has_key?(:object) }.returns("")
      end
    
      should "create default verbiage" do
       assert_difference 'Content.count' do 
         verbiage(:main) {"this is my default content"}
        end
      end
      
    end
    
  end
  
end