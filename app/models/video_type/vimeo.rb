class VideoType::Vimeo < Video
  
  def lookup
    "vimeo_#{self.clip_id}"
  end
  
  def embed_html(options = {})
    options = {:width => 400, :height => 302, :allowfullscreen => true, :allowscriptaccess => "always",
      :color => "00ADEF", :show_title => true, :show_byline => true, :show_portrait => false }.merge(options)
    <<-EOS
      <object width="#{options[:width]}" height="#{options[:height]}">
        <param name="allowfullscreen" value="#{options[:allowfullscreen]}" />
        <param name="allowscriptaccess" value="#{options[:allowscriptaccess]}" />
        <param name="wmode" value="transparent"> 
        <param name="movie" value="http://vimeo.com/moogaloop.swf?clip_id=#{clip_id}&amp;server=vimeo.com&amp;show_title=#{options[:show_title] ? "1" : "0"}&amp;show_byline=#{options[:show_byline] ? "1" : "0"}&amp;show_portrait=#{options[:show_portrait] ? "1" : "0"}&amp;color=#{options[:color]}&amp;fullscreen=#{options[:allowfullscreen] ? "1" : "0"}" />
        <embed src="http://vimeo.com/moogaloop.swf?clip_id=#{clip_id}&amp;server=vimeo.com&amp;show_title=#{options[:show_title] ? "1" : "0"}&amp;show_byline=#{options[:show_byline] ? "1" : "0"}&amp;show_portrait=#{options[:show_portrait] ? "1" : "0"}&amp;color=#{options[:color]}&amp;fullscreen=#{options[:allowfullscreen] ? "1" : "0"}" type="application/x-shockwave-flash" allowfullscreen="#{options[:allowfullscreen]}" allowscriptaccess="#{options[:allowscriptaccess]}" width="#{options[:width]}" height="#{options[:height]}" wmode="transparent"></embed>
      </object>
    EOS
  end

   def self.find_remote_by_tag(options)
    vimeo_video = Vimeo::Advanced::Video.new(options[:api_key], options[:secret])
    
    request_options = {}
    request_options[:user_id] = options[:username] if options.has_key?(:username)
    request_options[:per_page] = 50
    
    videos = vimeo_video.get_list_by_tag(options[:tag], request_options)
    videos.collect do |video|
      self.initialize_from_vimeo(video)
    end
  end
  
  def self.find_remote_by_username(username)
    videos = []
    page = []
    page_number = 1
    
    until page == false
      page = Vimeo::Simple::User.clips(username, :page => page_number)
      
      if page.is_a?(Array)
        page = page.collect do |video|
          self.initialize_from_vimeo(video)
        end
        videos = videos + page
        page_number += 1
      end
    end
    
    videos
  end
  
  def self.find_remote_by_clip_id(clip_id)
    Vimeo::Simple::Clip.info(clip_id).collect do |video|
      self.initialize_from_vimeo(video)
    end.first
  end
  
  def self.find_remote(options)
    if options.has_key?(:tag)
      self.find_remote_by_tag(options)
    elsif options.has_key?(:username)
      self.find_remote_by_username(options[:username])
    elsif options.has_key?(:clip_id)
      self.find_remote_by_clip_id(options[:clip_id])
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