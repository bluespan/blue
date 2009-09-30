class Video < ActiveRecord::Base

  @@remote_sources = []

  def duration
    Time.at(duration_in_seconds.to_i).gmtime.strftime('%R:%S').gsub(/^(00:)*/, "")
  end
  
  class << self
    def config(&block)
      yield self
    end
    
    def add_source(type, options = {})
      case type
        when :vimeo 
          @@remote_sources << Proc.new { VideoType::Vimeo.find_remote(options) }
      end
    end
    
    def find_remote(type = :all, options = {})
      if (type == :all)
        @@remote_sources.collect { |source| source.call }.flatten
      else (type == :vimeo)
        VideoType::Vimeo.find_remote(options)
      end
    end
    
    def find_by_lookup(lookup)
      type, clip_id = lookup.split("_")
      (VideoType.const_get(type.camelcase)).find_remote(:clip_id => clip_id)
    end
    
    def sources
      @@remote_sources
    end
    
    def clear_sources
      @@remote_sources == @@remote_sources.clear
    end
  end
  
end