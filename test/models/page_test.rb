require File.dirname(__FILE__) + '/../test_helper'

class PageTest < ActiveSupport::TestCase

  context "Page with content" do
    setup do 
      @page = Page.create(:title => "Home Page")
      @content = Content.create(:title => "main", :contentable_type => "Page", :contentable_id => @page.id, :content => "this is my default content")
    end
    
    should "should find content" do
      assert_equal @content, @page.content.first
    end
  end
  
  context "A new contentable homepage" do
    setup do
      @home_page = PageTypes::HomePage.create(:title => "Home")
    end
    
    should "be able to be assigned content" do
      content = Content.create(:title => "main", :content => "This is my homepage copy")
      @home_page.content << content
      
      assert_equal content, @home_page.content.first
      assert_equal "Page", content.contentable_type
      assert_equal @home_page.id, content.contentable_id
    end
    
    should "be able to be assigned verbiage content" do
      assert_equal 0, @home_page.verbiage.size
      assert_nil @home_page.verbiage[:main]
      
      assert_difference 'Content.count' do
        @home_page.verbiage[:main] = "this is my homepage verbiage"
        assert_equal "this is my homepage verbiage", @home_page.verbiage[:main].content
        assert_equal @home_page.id, @home_page.verbiage[:main].contentable_id
        assert_equal "Verbiage", @home_page.verbiage[:main].type
      end
      
      assert_equal 1, @home_page.verbiage.size
    end
    
    should "publish content on publish" do
      @home_page.verbiage[:main] = "this is my homepage verbiage"
      assert @home_page.pending_publish?
      assert_difference 'Page.count' do
        assert_difference 'Content.count' do
          published_home = @home_page.publish
          assert_equal @home_page.verbiage[:main].content,
                       published_home.verbiage[:main].content
        end
      end
    end
    
  end
  
  # context "Video Page" do
  #    
  #    setup do
  #      Video.config do |video|
  #        video.add_source :vimeo, :username => "stevep"
  #      end
  #    end
  #    
  #    context "Caching a video" do
  #      setup do
  #        @video_page = PageTypes::VideoPage.create(:template_file => "video.html.erb", :title => "My Video Page")
  #      end
  #      
  #      should "cache" do
  #        assert_difference 'Video.count' do 
  #          @video_page.video_lookup = "vimeo_2029334"
  #          @video_page.cache_video!
  #        end
  #      end
  #    end
  #    
  #    context "Creating Page with video" do    
  #      
  #      should "create page" do
  #        assert_difference "Page.count", 1 do
  #          PageTypes::VideoPage.create(:template_file => "video.html.erb", :title => "My Video Page", :video_lookup => "vimeo_2012653")
  #        end
  #      end
  #      
  #      should "create video" do
  #        assert_difference "Video.count", 1 do
  #          PageTypes::VideoPage.create(:template_file => "video.html.erb", :title => "My Video Page", :video_lookup => "vimeo_2012653")
  #        end
  #      end
  #    end
  #    
  #    context "Creating Page without video" do
  #      setup do
  #        @video_page = PageTypes::VideoPage.create(:template_file => "video.html.erb", :title => "My Video Page")
  #      end
  #      
  #      should_change "Page.count"
  #      should_not_change "Video.count"  
  #    end
  #    
  #    context "Updating Page with new video" do
  #      setup do
  #        @video_page = PageTypes::VideoPage.create(:template_file => "video.html.erb", :title => "My Video Page", :video_lookup => "vimeo_2012653")
  #      end
  #      
  #      should "cache new video" do 
  #        assert_difference 'Video.count' do 
  #          @video_page.video_lookup = "2029334"
  #          @video_page.save
  #          assert_equal "2029334", @video_page.video.clip_id
  #        end
  #      end      
  #    end
  #    
  #    context "Updating Page with same video" do
  #      setup do
  #        @video_page = PageTypes::VideoPage.create(:template_file => "video.html.erb", :title => "My Video Page", :video_lookup => "vimeo_2012653")
  #      end
  #      
  #      should "not cache new video" do 
  #        assert_no_difference 'Video.count' do 
  #          @video_page.video_lookup = "2012653"
  #          @video_page.save
  #          
  #          assert_equal "2012653", @video_page.video.clip_id
  #        end
  #      end      
  #    end    
  #      
  #      
  #  end
  
end