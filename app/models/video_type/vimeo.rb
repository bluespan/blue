class VideoType::Vimeo < Video
  
  def self.find_by_username(username)
    Vimeo::Simple::User.clips(username).collect do |video|
      self.initialize_from_vimeo(video)
    end
  end
  
  private
  
  def self.initialize_from_vimeo(video)
    VideoType::Vimeo.new({
      :clip_id => video["clip_id"],
      :title => video["title"],
      :description => video["caption"],
      :duration_in_seconds => video["duration"],
      :thumbnail => video["thumbnail_medium"],
      :url => video["url"]
    })
  end
  
end