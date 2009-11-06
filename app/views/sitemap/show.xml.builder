xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do

  @pages.each do |page|
   
    xml.url do
      if page.is_a?(PageTypes::HomePage)
        xml.loc         "http://#{@host}" 
      else
        xml.loc         "http://#{@host}#{page.url}" 
      end
      xml.lastmod     page.updated_at.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    end

  end
end