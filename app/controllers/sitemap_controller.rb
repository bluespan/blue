class SitemapController < ApplicationController
  
  def show
    @host = "#{request.host}#{(request.port != 80 ? ":"+request.port.to_s : "")}"
    @pages = Page.live
    respond_to do |wants|
      wants.xml
    end
  end
  
end