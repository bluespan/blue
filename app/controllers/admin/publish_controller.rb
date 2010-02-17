class Admin::PublishController < Admin::PagesController
  
  def index
    
  end
  
  def destroy
    @page.revert_to_live
    flash.now[:notice] = "#{@page.display_name} <em>#{@page.title}</em> was successfully <em>reverted.</em>"
    respond_to do |wants|
      wants.js { render :template => "admin/publish/destroy.js" }
    end
  end
  
end
