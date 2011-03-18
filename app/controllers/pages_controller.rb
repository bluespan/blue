class PagesController < BlueController
  unloadable

  include Span::Blue::Routing

  def home
    @page = PageTypes::HomePage.working.find(:first)
    @page = live_or_working @page
    if @page.nil?
      render :template => "pages/coming_soon.html.erb"
    else
      show
    end
  end
  
  def show   
    render_instructions = handle_request 
    unless render_instructions.nil?
      if (render_instructions.has_key?(:redirect_to))
        redirect_to render_instructions[:redirect_to]
      else
        render render_instructions 
      end
    end
        
    rescue BlueTempateFileNotFound
      render :template => "errors/blue_template_file_not_found", :layout => "blue_error"
  end
  
  protected
  
  def handle_request
    @params = params
    @slugs ||= request.path.split("/").delete_if {|slug| slug == ""}

    render_instructions = {}
    ancestors = ""
    
    # Set Locale
    if blue_features.include?(:localization)
      if params[:locale].nil?
        Span::Blue.locales.each do |locale|
          if @slugs.length > 0 && @slugs[0] == locale.to_s
            I18n.locale = locale
            @slugs.shift
            break
          end
        end
      else
        I18n.locale = params[:locale]
      end
    end

    @slugs.each_index do |index|
      slug = @slugs[index]
      @slug_index = index
      leaf = index == @slugs.length - 1
      
      @page = load_page(slug, ancestors, leaf)
      
      return nil unless @page.is_a?(Page)
      @page.request_params = @params
      
      if @page.respond_to? :require_ssl? and @page.require_ssl? 
        if !request.ssl? && RAILS_ENV == "production"
          redirect_to "https://" + request.host + request.request_uri 
          return nil
        end
      end
      
      if @page.is_a?(Collection) && !leaf && index == @slugs.length - 2
        item_model = @page.collects.classify.constantize
        @collection = @page
        @item = item_model.column_names.include?("slug") ? item_model.find_by_slug(@slugs[index+1]) : item_model.find(@slugs[index+1])
        if (@item)
          @item.class.view_paths.each { |view_path| self.view_paths.unshift view_path }
          @page = @item.proxy_page(live_or_working)
          break
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