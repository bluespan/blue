require File.dirname(__FILE__) + '/../test_helper'

class VideoTest < Test::Unit::TestCase

  context "Vimeo Videos" do
    should "return a listing by username" do
      Vimeo::Simple::User.expects(:clips).with("stevep").returns(results_for_vimeo_find_remote_by_username_stevep)
      
      videos = VideoType::Vimeo.find_remote_by_username("stevep")
      assert_equal 4, videos.length
      
      assert_equal "2029334", videos.first.clip_id
      assert_equal "Jill's 2007 State Science Fair", videos.first.title
      assert_equal "The Journey of Jill's May 2007 Illinois State Science Fair", videos.first.description
      assert_equal "24:36", videos.first.duration
      assert_equal "http://images.vimeo.com/16/72/52/167252808/167252808_200.jpg", videos.first.thumbnail
      assert_equal "http://vimeo.com/2029334", videos.first.url
    end
  end
  
  context "Configuring Videos" do
    
    setup do
      # Clear all sources before each test
      Video.clear_sources
    end

    should "be allow for adding sources" do
      Video.expects(:add_source).with(:vimeo, :username => "stevep")

      Video.config do |video|
        video.add_source :vimeo, :username => "stevep"
      end
    end
    
    should "be able to clear sources" do
      Video.config do |video|
        video.add_source :vimeo, :username => "stevep"
      end
      
      assert_equal 1, Video.sources.length
      
      Video.clear_sources
      assert_equal 0, Video.sources.length
    end
        
    should "be able to add a source from vimeo by username" do
      Video.config do |video|
        video.add_source :vimeo, :username => "stevep"
      end
      
      Vimeo::Simple::User.expects(:clips).with("stevep").returns(results_for_vimeo_find_remote_by_username_stevep)
      
      videos = Video.find_remote(:all)
      assert_equal 4, videos.length
    end
    
    should "be able to find a video by clip id" do
      
      Vimeo::Simple::Clip.expects(:info).with("2029334").returns(results_for_vimeo_find_remote_by_clip_id)

      video = Video.find_remote(:vimeo, :clip_id => "2029334")
      
      assert_equal "vimeo_2029334", video.lookup
    end
    
    should "be able to find a video by video_lookup string" do
      
      Vimeo::Simple::Clip.expects(:info).with("2029334").returns(results_for_vimeo_find_remote_by_clip_id)

      video = Video.find_by_lookup("vimeo_2029334")
      
      assert_equal "vimeo_2029334", video.lookup
    end
  end
  
  private
  
  def results_for_vimeo_find_remote_by_username_stevep
     [{"user_thumbnail_small"=>"http://images.vimeo.com/11/35/27/113527888/113527888_30.jpg", "thumbnail_large"=>"http://bitcast.vimeo.com/vimeo/thumbnails/defaults/default.300x400.jpg", "stats_number_of_plays"=>"6", "thumbnail_small"=>"http://images.vimeo.com/16/72/52/167252808/167252808_100.jpg", "title"=>"Jill's 2007 State Science Fair", "tags"=>"Jill", "stats_number_of_likes"=>"0", "clip_id"=>"2029334", "url"=>"http://vimeo.com/2029334", "user_url"=>"http://vimeo.com/stevep", "upload_date"=>"2008-10-21 14:51:39", "stats_number_of_comments"=>0, "caption"=>"The Journey of Jill's May 2007 Illinois State Science Fair", "height"=>"380", "user_thumbnail_huge"=>"http://images.vimeo.com/11/35/27/113527888/113527888_300.jpg", "thumbnail_medium"=>"http://images.vimeo.com/16/72/52/167252808/167252808_200.jpg", "duration"=>"1476", "user_thumbnail_large"=>"http://images.vimeo.com/11/35/27/113527888/113527888_100.jpg", "user_name"=>"Steve Pfisterer", "width"=>"504", "user_thumbnail_medium"=>"http://images.vimeo.com/11/35/27/113527888/113527888_75.jpg"}, {"user_thumbnail_small"=>"http://images.vimeo.com/11/35/27/113527888/113527888_30.jpg", "thumbnail_large"=>"http://bitcast.vimeo.com/vimeo/thumbnails/defaults/default.300x400.jpg", "stats_number_of_plays"=>"21", "thumbnail_small"=>"http://images.vimeo.com/16/56/41/165641451/165641451_100.jpg", "title"=>"Jill Gymnastics Meet - 11-05-2006", "tags"=>"", "stats_number_of_likes"=>"0", "clip_id"=>"2012653", "url"=>"http://vimeo.com/2012653", "user_url"=>"http://vimeo.com/stevep", "upload_date"=>"2008-10-19 22:48:03", "stats_number_of_comments"=>0, "caption"=>"Jill gymnastics meet on November 5th, 2006", "height"=>"380", "user_thumbnail_huge"=>"http://images.vimeo.com/11/35/27/113527888/113527888_300.jpg", "thumbnail_medium"=>"http://images.vimeo.com/16/56/41/165641451/165641451_200.jpg", "duration"=>"702", "user_thumbnail_large"=>"http://images.vimeo.com/11/35/27/113527888/113527888_100.jpg", "user_name"=>"Steve Pfisterer", "width"=>"504", "user_thumbnail_medium"=>"http://images.vimeo.com/11/35/27/113527888/113527888_75.jpg"}, {"user_thumbnail_small"=>"http://images.vimeo.com/11/35/27/113527888/113527888_30.jpg", "thumbnail_large"=>"http://bitcast.vimeo.com/vimeo/thumbnails/defaults/default.300x400.jpg", "stats_number_of_plays"=>"21", "thumbnail_small"=>"http://images.vimeo.com/16/69/41/166941712/166941712_100.jpg", "title"=>"Woot - Bag Of Crap", "tags"=>"", "stats_number_of_likes"=>"1", "clip_id"=>"2012499", "url"=>"http://vimeo.com/2012499", "user_url"=>"http://vimeo.com/stevep", "upload_date"=>"2008-10-19 22:23:06", "stats_number_of_comments"=>0, "caption"=>"Opening my first bag of crap.", "height"=>"380", "user_thumbnail_huge"=>"http://images.vimeo.com/11/35/27/113527888/113527888_300.jpg", "thumbnail_medium"=>"http://images.vimeo.com/16/69/41/166941712/166941712_200.jpg", "duration"=>"150", "user_thumbnail_large"=>"http://images.vimeo.com/11/35/27/113527888/113527888_100.jpg", "user_name"=>"Steve Pfisterer", "width"=>"504", "user_thumbnail_medium"=>"http://images.vimeo.com/11/35/27/113527888/113527888_75.jpg"}, {"user_thumbnail_small"=>"http://images.vimeo.com/11/35/27/113527888/113527888_30.jpg", "thumbnail_large"=>"http://bitcast.vimeo.com/vimeo/thumbnails/defaults/default.300x400.jpg", "stats_number_of_plays"=>"26", "thumbnail_small"=>"http://images.vimeo.com/16/74/08/167408318/167408318_100.jpg", "title"=>"Jill Gymnastics - Beam Routine", "tags"=>"", "stats_number_of_likes"=>"0", "clip_id"=>"2012404", "url"=>"http://vimeo.com/2012404", "user_url"=>"http://vimeo.com/stevep", "upload_date"=>"2008-10-19 22:11:31", "stats_number_of_comments"=>0, "caption"=>"Supernatural events occur as Jill performs her beam routine. Unfortunately, vimeo wants to cut off the first 3 sec of the video making the audio out of sync.", "height"=>"380", "user_thumbnail_huge"=>"http://images.vimeo.com/11/35/27/113527888/113527888_300.jpg", "thumbnail_medium"=>"http://images.vimeo.com/16/74/08/167408318/167408318_200.jpg", "duration"=>"123", "user_thumbnail_large"=>"http://images.vimeo.com/11/35/27/113527888/113527888_100.jpg", "user_name"=>"Steve Pfisterer", "width"=>"504", "user_thumbnail_medium"=>"http://images.vimeo.com/11/35/27/113527888/113527888_75.jpg"}]  
  end
  
  def results_for_vimeo_find_remote_by_clip_id
     [{"user_thumbnail_small"=>"http://images.vimeo.com/11/35/27/113527888/113527888_30.jpg", "thumbnail_large"=>"http://bitcast.vimeo.com/vimeo/thumbnails/defaults/default.300x400.jpg", "stats_number_of_plays"=>"6", "thumbnail_small"=>"http://images.vimeo.com/16/72/52/167252808/167252808_100.jpg", "title"=>"Jill's 2007 State Science Fair", "tags"=>"Jill", "stats_number_of_likes"=>"0", "clip_id"=>"2029334", "url"=>"http://vimeo.com/2029334", "user_url"=>"http://vimeo.com/stevep", "upload_date"=>"2008-10-21 14:51:39", "stats_number_of_comments"=>0, "caption"=>"The Journey of Jill's May 2007 Illinois State Science Fair", "height"=>"380", "user_thumbnail_huge"=>"http://images.vimeo.com/11/35/27/113527888/113527888_300.jpg", "thumbnail_medium"=>"http://images.vimeo.com/16/72/52/167252808/167252808_200.jpg", "duration"=>"1476", "user_thumbnail_large"=>"http://images.vimeo.com/11/35/27/113527888/113527888_100.jpg", "user_name"=>"Steve Pfisterer", "width"=>"504", "user_thumbnail_medium"=>"http://images.vimeo.com/11/35/27/113527888/113527888_75.jpg"}]  
  end

end