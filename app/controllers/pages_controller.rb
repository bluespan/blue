class PagesController < BlueController
  unloadable

  include Span::Blue::Routing

  def home
    @page = PageTypes::HomePage.working.find(:first)
    if live_or_working(@page).nil?
      @page = live_or_working @page
      render :template => "pages/coming_soon.html.erb"
    else
      show
    end
  end
  
  def show   
    render_instructions = handle_request 
    render render_instructions unless render_instructions.nil?
        
    rescue BlueTempateFileNotFound
      render :template => "errors/blue_template_file_not_found", :layout => "blue_error"
  end
  
  protected
  
  def handle_request
    @slugs ||= request.path.split("/").delete_if {|slug| slug == ""}

    render_instructions = {}
    ancestors = ""

    @slugs.each_index do |index|
      slug = @slugs[index]
      @slug_index = index
      
      @page = load_page(slug, ancestors)
      
      if Page.allow_ssl and @page.require_ssl? 
        unless request.ssl?
          redirect_to "https://" + request.host + request.request_uri 
          return nil
        end
      end
      
      if not @page.nil? 
        instructions = route
        if instructions.is_a?(Hash)
          render_instructions = instructions
          break
        end
      else
        return {:status => 404, :template => "pages/404.html.erb"}
      end
      
      ancestors += "/#{slug}"
    end
    
    return {:template => @page.template.path}.merge(render_instructions)
  end
  

end