module Admin::AssetsHelper
  def asset_image_path(asset)
    asset_path(asset)
  end
  
  def asset_path(asset)
    controller.request.path + "/" + asset.filename
  end
  
  def current_asset_path
    controller.request.path.gsub(/\/admin\/assets\/(viewer|selector)\/?/, "")
  end
  
  def asset_breadcrumbs(viewer = "viewer", &block)
    concat link_to("Assets", "/admin/assets/#{viewer}", :class => "directory")
    url = "/admin/assets/#{viewer}"
    current_asset_path.split("/").compact.each do |folder| 
    	url += "/#{folder}"
    	concat capture(folder.gsub("%20", " "), url, &block)
    end
  end
  
  def asset_css_class(asset)
    if Asset.directory?(asset.path)
      return "directory"
    else
      return "file"
    end
  end
end
