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
    @slugs ||= request.path.split("/").delete_if {|slug| slug == ""}

    render_instructions = {}
    ancestors = ""

    @slugs.each_index do |index|
      slug = @slugs[index]
      @slug_index = index
      
      @page = load_page(slug, ancestors)
      if not @page.nil? 
        instructions = route
        if instructions.is_a?(Hash)
          render_instructions = instructions
          break
        end
      else
        render_instructions = {:status => 404, :template => "pages/404.html.erb"}
        break
      end
      
      ancestors += "/#{slug}"
    end
    
    unless @page.nil?
      render_instructions = {:template => @page.template.path}.merge(render_instructions)
    end
    
    render render_instructions
    
    
  rescue BlueTempateFileNotFound
    render :template => "errors/blue_template_file_not_found", :layout => "blue_error"
    
  end

end