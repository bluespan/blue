class SitemapController < PagesController
  
  def index
    show
  end
  
  def show
    @host = "#{request.host}#{(request.port != 80 ? ":"+request.port.to_s : "")}"
    @pages = Page.live
    respond_to do |wants|
      wants.xml
      wants.html { super }
    end
  end
  
end