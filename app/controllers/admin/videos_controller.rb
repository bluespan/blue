class Admin::VideosController < Admin::BlueAdminController
  
  def index
    @videos = Video.find_remote(:all)
    render :layout => false
  end
  
end
