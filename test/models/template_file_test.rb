require File.dirname(__FILE__) + '/../test_helper'

class TemplateFileTest < Test::Unit::TestCase

  context "Templates that exist" do
    should "return the template file and not raise an exception" do
      @template_file = mock('template_file')
      TemplateFile.expects(:exist?).returns true
      TemplateFile.expects(:new).returns(@template_file)
      
      assert_nothing_raised do
        assert_equal @template_file, TemplateFile.find("home.html.erb")
      end
    end
  end

  context "Templates that don't exist" do
    should "raise an exception when a find is attempted" do
      e = assert_raise(BlueTempateFileNotFound) { TemplateFile.find("home.html.erb") }
      
      assert_equal e.message[:template_file], "home.html.erb"
      assert_not_nil e.message[:path]
    end
  end
  

end