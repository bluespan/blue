require File.dirname(__FILE__) + '/../test_helper'

class GalleryTest < ActiveSupport::TestCase

  context "A New Gallery" do
    setup do 
      @gallery = Gallery.new
      @christmas_gallery_attributes = {:title => "Christmas 2009", :content => "Pictures from Christmas Morning in the Smith house hold."}
    end
    
    should "should save" do
      @gallery.attributes = @christmas_gallery_attributes
      assert_difference 'Page.count' do
        @gallery.save
        assert_equal @christmas_gallery_attributes.title, @gallery.title
      end
    end
    
    should "have no photos" do
      assert_equal @gallery.photos.length, 0
    end
  end
  
end