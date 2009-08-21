class PageTypes::VideoPage < Page
  
  belongs_to :video
  
  attr_accessor :video_lookup
  
  before_save :cache_video!, :unless => 'video_lookup.nil?'
  
  configure_blue_page do |page| 
    page.type_name = "Video"
  end
  
  def cache_video!
    raise "No video to cache, please select a video" if video_lookup.nil?
    
    return true if video and video.lookup == video_lookup
    
    video_to_cache = Video.find_by_lookup(video_lookup)
    video_to_cache.save
    
    self.video = video_to_cache
  end
 
end