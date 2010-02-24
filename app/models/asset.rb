class Asset < File
  
  require 'fileutils'
  
  def initialize(path, options)
    super(path)
    @options = { :dir => BLUE_ASSETS_ROOT }.merge(options)
  end
  
  def filename
    path.sub(/^.+\/([^\/]+.+)$/) { |match| $1 }
  end
  
  def filepath
    path.gsub(@options[:dir], "")
  end
  
  def protected?
    (assetpath == "/documents") or (assetpath == "/images") 
  end
  
  def assetpath
    path.gsub(BLUE_ASSETS_ROOT, "")
  end
  
  def relative_filepath
    filepath.gsub(/^\//, "")
  end
  
  def fileurl
    "/assets/"+filepath
  end
  
  def extension
    File.extname(path).gsub(/^\./, "").downcase
  end

  def thumbnail_url
    return '/images/blue/folder.jpg' if File.directory?(path)
    return '/images/blue/page_pdf.png' if extension == "pdf"
    return '/images/blue/page_word.png' if extension == "doc" || extension == "docx"
    return '/images/blue/page.png'
  end
  
  def destroy
    if protected? == false      
      if File.directory?(path)
        FileUtils.remove_dir(path)
      else
        File.delete(path)
      end
    else
      raise Exception, "Asset '#{assetpath}' is protected"
    end
  end
  
  def self.find(file, options = {})
    options = { :dir => BLUE_ASSETS_ROOT, 
                :include_directories => true }.merge(options)
    
    return Asset.initialize_asset_type(options[:dir] + "/" + file, options) if file.kind_of?(String)
    
    assets =  Dir.new(options[:dir]+"/").collect do |file|
                asset = Asset.initialize_asset_type(options[:dir] + "/" + file, options) if file.match(/^\..*$/).nil?
              end.compact
    
    assets.delete_if { |file| File.directory?(file) } if options[:include_directories] == false          
    assets.delete_if { |file| File.directory?(file) && file.filename == "admin_users" }

    assets.sort! { |x,y| x.filename.downcase <=> y.filename.downcase }
    return assets
  end
  
  def self.initialize_asset_type(path, options)
    case self.extname(path).downcase
    when ".gif", ".jpg", ".jpeg", ".tiff", ".bmp", ".png"
      Asset::Image.new(path, options)
    else
      Asset.new(path, options)
    end
  end
 
  
end

class Asset::Image < Asset
  
  THUMBNAIL_DIR = '.thumbnails'
  
  def thumbnail
    if path.include?("/assets/images/")
      @thumbnail ||= Asset::Image::Thumbnail.new(self , @options)
    else
      @thumbnail ||= self
    end
  end
  
  def thumbnail_url
    '/assets/'+thumbnail.path.gsub(BLUE_ASSETS_ROOT, "")
  end
 
  def self.find(file, options = {})
    assets = super(file, options)
    assets.delete_if { |file| file.kind_of?(Asset::Image) == false && File.directory?(file) == false }
  end

  
  def close
    @thumbnail.close unless @thumbnail.nil? || @thumbnail == self
    super
  end
  
  def destory
    File.delete(thumbnail.path)
    super
  end
  
end

class Asset::Image::Thumbnail < Asset::Image
 
 # require 'rubygems'
 # require 'image_science'
 
  def initialize(image, options)

    # Determine Thumbnail Path
    image_path =  options[:dir].sub(BLUE_ASSETS_ROOT + "images", "") + "/";
    thumbnail_dir = BLUE_ASSETS_ROOT + "images/" + THUMBNAIL_DIR
    thumbnail_path = thumbnail_dir + image_path + image.filename
    # 
    create(thumbnail_path) unless File.exists?(thumbnail_path) && File.mtime(thumbnail_path) > image.mtime
    super(thumbnail_path, options)
  end
  
 def create(path)
   FileUtils.mkdir_p(path.gsub(/\/[^\/]*$/, "")) 
   ImageScience.with_image(path.gsub("/" + THUMBNAIL_DIR, "")) do |img|
     img.thumbnail("100>") do |thumb|
       thumb.save path
     end
   end
 end

end