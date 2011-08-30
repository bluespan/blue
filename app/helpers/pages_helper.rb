module PagesHelper
  
  def blue_include
    concat stylesheet_link_admin  if logged_in?
    concat javascript_include_tag "blue/jquery/jquery.simplemodal-1.1.1.js"  if logged_in?
  	concat javascript_include_tag "blue/jquery/jquery.mousewheel.js"  if logged_in? 
  	concat javascript_include_tag "blue/wymeditor/jquery.wymeditor.js" if logged_in? 
  	concat javascript_include_tag "blue/wymeditor/plugins/blue/jquery.wymeditor.blue.image_dialog.js" if logged_in? 
  	concat javascript_include_tag "blue/wymeditor/plugins/blue/jquery.wymeditor.blue.link_dialog.js" if logged_in? 
  	concat javascript_include_tag "blue/jquery/jquery.easing.min.js" if logged_in? 
  	concat javascript_include_tag "blue/jquery/jquery.lavalamp.min.js" if logged_in?  
  	concat javascript_include_tag "blue/jquery/jquery.hoverIntent.js" if logged_in? 
  	concat javascript_include_tag 'blue/jquery/jquery.jgrowl' if logged_in? 
  	concat javascript_include_tag 'blue/jquery/jquery.checkbox.min' if logged_in? 
  	concat javascript_include_tag 'blue/jquery/jquery.checkboxes.pack' if logged_in? 

  	concat javascript_include_tag('blue/admin/verbiage') if logged_in? 
  	concat javascript_include_tag "blue/logged_in.js" if logged_in?
  	
  end
  
  def verbiage(key, options = {}, &default_block)
    options = {:contentable => @page, :partial => "verbiage"}.merge(options)
    return if options[:contentable].nil?
    
    global_verbiage(key, options, &default_block)  
  end
  
  def verbiage_field(key, options = {}, &default_block)
    options = {:partial => "field", :contentable => @item, :field_prefix => "contentable"}.merge(options)
    return if options[:contentable].nil?
    
    default_content = block_given? ? capture(&default_block) : nil
    
    init_verbiage(key, options, default_content)
    verbiage = options[:contentable].verbiage[key.to_sym][I18n.locale.to_s]
    verbiage = options[:contentable].verbiage[key.to_sym][Span::Blue.locales.first.to_s] if verbiage.nil?
    
    concat render(:partial => "admin/verbiage/#{options[:partial]}", :object => verbiage, :locals => {:options => options})
    
  end
  
  def global_verbiage(key, options = {}, &default_block)    
      options = {:partial => "global_verbiage", :admin => true, :editor => "wymeditor", :members_only => false, :return => :concat}.merge(options)
      default_content = block_given? ? capture(&default_block) : nil
      
      if (options[:contentable].nil?)
        Span::Blue.locales.each do |locale|
          g = GlobalVerbiage.get(key, locale)
          if g.new_record?
            g.content = default_content
            g.members_only = options[:members_only]
            g.save!
          end
        end
        verbiage = GlobalVerbiage.get(key, I18n.locale)
      else
        init_verbiage(key, options, default_content)
        verbiage = options[:contentable].verbiage[key.to_sym][I18n.locale.to_s]
        verbiage = options[:contentable].verbiage[key.to_sym][Span::Blue.locales.first.to_s] if verbiage.nil?
      end
      
      
      if logged_in? && options[:admin]
        output = render(:partial => "admin/verbiage/#{options[:partial]}", :object => verbiage, :locals => {:options => options})
      else
        output = verbiage.content unless verbiage.members_only? and member_logged_in? == false and logged_in? == false
      end
      
      if options[:return] == :concat
        concat output
      else
        return output
      end      
  end
  
  
  def content_placement(title, options = {}, &default_block)
    # options = {}.merge(options)
    default_content = block_given? ? capture(&default_block) : nil
    options[:default_content] = default_content
    
    placement = ContentPlacement.find_by_title_and_page_id(title.to_s.underscore, @page.id) || ContentPlacement.new({:title => title.to_s.underscore, :page_id => @page.id })

    concat render(:partial => "content/placement", :object => placement, :locals => {:options => options}) # unless verbiage.members_only? and member_logged_in? == false and logged_in? == false
  end
  
  def navigation(top, options = {})
    options = {:levels => 9999, :top_levels => 9999, :id => "#{top.to_s}_navigation",
                :exclude => nil, :include => nil,
                :collapsed => false, :force_display => false}.update(options)
    
    options[:current_page] = @page if options.has_key?(:current_page) == false or options[:current_page].nil? 
    
    if @page and options[:levels].is_a?(Hash) and options[:levels].has_key?(:from)
        options[:id] = "#{options[:id]}_level_#{options[:levels][:from]}"
        nav = @page.version(:working).navigations.select { |navigation| navigation.root.title.downcase == top.to_s.downcase }.first
        nav = @page.version(:working).navigations.first if nav.nil?
        @top = nav.self_and_ancestors[options[:levels][:from] - 1] 
        url = @top.url(:working)
    elsif top.is_a?(Navigation)
      @top = top
      url = "/#{top.page.slug}"
    else
      @top = Navigation.bookmark(top)
    end
    
    options[:levels] = { :limit => options[:levels] } unless options[:levels].is_a?(Hash)
    
    output =  "<ul id=\"#{options[:id]}\""
    output += " class=\"#{options[:class]}\"" if options[:class] 
    output += ">"
    
    children = navigation_children(@top)
    children = children.slice(0..(options[:top_levels]-1))
    if options[:levels].is_a?(Hash) and options[:levels].has_key?(:include_parent) 
      @top.title = options[:levels][:include_parent] if options[:levels][:include_parent].is_a?(String)
      children = children.unshift(@top) 
    end  
      
    output += navigation_tree(children, options, url) unless @top.nil?
    output += "</ul>"
  end
  
  def rewire_navigation_tree(parent_id, new_parent_id)
    rewired_navigation_tree(parent_id, new_parent_id)
  end
  
  def rewired_navigation_tree(parent_id = nil, new_parent_id = nil)
    @rewired_navigation_tree ||= {}
    @rewired_navigation_tree[parent_id] = new_parent_id unless parent_id.nil? || new_parent_id.nil?
    @rewired_navigation_tree
  end
  
  def navigation_children(top)
    @navigation_descendant_tree ||= {}
    return @navigation_descendant_tree[rewired_navigation_tree[top.id] || top.id] if @navigation_descendant_tree.has_key?(top.id)
    @navigation_descendant_tree = @navigation_descendant_tree.merge(top.descendant_tree)
    
    return @navigation_descendant_tree[rewired_navigation_tree[top.id] || top.id]
  end
  
  def breadcrumbs(options = {})
    options = {:navigation => @navigation, :delimiter => " / ", :link_current_page => true, :include_current_page => true}.update(options)
    return if options[:navigation].nil?
    
    pages = @navigation.self_and_ancestors.delete_if{|navigation| navigation.root? }.collect{|n| n.page }
    pages = pages.collect { |c| live_or_working c}
    
    pages.push(@page) unless pages.include?(@page)
    pages = pages.delete_if { |page| page == @page } unless options[:include_current_page]
    
    pages.collect do |page|
      (options[:link_current_page] || @page != page ) ? (link_to page.l10n_attribute(:title), i18n_url(page.url), :class => (@page == page) ? "current" : "") :  content_tag(:span, page.l10n_attribute(:title), :class => "current")
    end.join(options[:delimiter])
  end
  
  def body_attributes
    if @page
     return "id=\"#{@page.body_id || @page.slug}\" class=\"#{@page.body_class || @page.template.css_class}\""
    else
      return "class=\"error\""
    end
  end
  
  def page_title
    return "" if @page.nil? || @page.class == PageTypes::HomePage
    " - #{@page.l10n_attribute(:title)}"
  end
  
  def working_page
    @working_page = @page.published? ? @page.working : @page
  end
  
  def search_highlite(result, field)
    (content = result.highlight(@search_query, :field => field, :num_excerpts => 2, :pre_tag => "<em>", :post_tag => "</em>")).blank? ? result.send(field).split(" ")[0..40].join(" ") : content
  end
  
  def sitemap(buckets = {})
    output = ""
    buckets.each do |bucket|
      output += navigation(bucket, :id => "#{bucket.to_s}_sitemap")
    end
    output
  end
  
  def embed_video(video, options = {})
    video.embed_html(options)
  end
  
  def video_paginate(options = {})
    options = {:page => 1, :include => {:page => :video}}.merge(options)
    @navigation.children.paginate(options)
  end
  
  def collection(model, *options, &template)
    conditions = {}
    options.each do |option|
      conditions.merge!(options.delete(option)) if option.is_a?(Hash)
    end
    scopes = options
        
    model = model.name if model.is_a? Class    
    item_model = model.to_s.tableize.classify.constantize
    scopes.delete_if { |scope| !item_model.scopes.has_key?(scope) }
   # scopes << conditions
    
    items = item_model
    scopes.each do |scope|
      items = items.send(scope)
    end
    
    if conditions.include?(:tagged_with_any)
      tagged_with = conditions.delete(:tagged_with_any)
      items = items.tagged_with(tagged_with, :any => true) unless tagged_with.empty?
    end
    
    if (conditions.include?(:paginate))
      conditions[:page] = @params[:page]
      conditions[:per_page] = conditions.delete(:paginate)
      items = items.paginate(conditions)
    else
      items = items.all(conditions)
    end
  
    html = ""
    items.each do |item|
      html += with_output_buffer { template.call(item) }
    end
    concat html
    
    items
  end  
  
  def i18n_url(url)
    return url unless blue_features.include?(:localization)
    if I18n.locale != Span::Blue.locales.first and (url =~ /^http/).nil?
      url = "/#{I18n.locale}#{url}"
    end
    url
  end
  
  private 
  
  def init_verbiage(key, options, default_content)
    unless options[:contentable].verbiage.has_key?(key)
      init_locale_verbaige(key, Span::Blue.locales.first.to_s, options, default_content)
    end
    
    # Span::Blue.locales.each do |locale|
    #   unless options[:contentable].verbiage[key].has_key?(locale.to_s)
    #     init_locale_verbaige(key, locale.to_s, options, default_content)
    #   end
    # end  
      
    options[:contentable]
  end
  
  def init_locale_verbaige(key, locale, options, default_content)
    options[:contentable].verbiage.set_verbiage(key, locale.to_s, default_content)
    if options[:members_only]
      options[:contentable].verbiage[key][locale].members_only = options[:members_only] 
      options[:contentable].verbiage[key][locale].save!
    end
    
    options[:contentable]
  end
  
  def navigation_tree(navigations, options = {}, url = "", level = 1)
    output = ""
    
    navigations = navigations.delete_if { |n| options[:exclude].call(n) } unless options[:exclude].nil?
    navigations = navigations.delete_if { |n| not options[:include].call(n) } unless options[:include].nil?
    
    navigations.each do |navigation|
      
      page = live_or_working navigation.page
      
      next if page.nil?
      next if blue_features.include?(:localization) && page.l10n_attribute(:enabled) == false
      next if (navigation.display? == false && options[:force_display] == false) || page.nil?
      next if navigation.display_to_members_only? && member_logged_in? == false
      next if page.class == PageTypes::MemberSignInPage && member_logged_in? == true
      next if page.class == PageTypes::MemberSignInPage && @page.class == PageTypes::MemberSignInPage
      next if page.class == PageTypes::MemberSignOutPage && member_logged_in? == false
      
        
      if page.class == PageTypes::HomePage
        navigation_url = "/"
        navigation_url = i18n_url("/home") unless I18n.locale == Span::Blue.locales.first or level > 1
      elsif options[:levels].is_a?(Hash) and options[:levels].has_key?(:include_parent) and navigation == navigations.first and level == 1
        navigation_url = url
        navigation_url = i18n_url("#{url}") unless I18n.locale == Span::Blue.locales.first or level > 1
      else  
        navigation_url = "#{url}/#{page.slug}"
        navigation_url = i18n_url("#{url}/#{page.slug}") unless I18n.locale == Span::Blue.locales.first or level > 1
      end
      
      #navigation_url = i18n_url("#{url}/#{page.slug}") unless I18n.locale == Span::Blue.locales.first or level > 1
    
      classes = []
      classes << cycle(*options[:classes][level]) if options[:classes] && options[:classes][level]
      if @navigation
       classes << "active"   if @navigation.self_and_ancestors_cached.include?(navigation)
      end  
      classes << "current"  if page.id == options[:current_page].id
      classes << "first"  if navigation == navigations.first
      classes << "last"   if navigation == navigations.last
      classes << "collapsed"   if navigation.collapsed?
      classes << "placeholder"   if navigation.placeholder?
      classes << page.slug.underscore
    
      if page.respond_to?(:link) 
        link_url =  page.link 
      elsif navigation.placeholder?
        link_url = "#"
      else
        if options[:use_alternate_urls] and (page_urls = page.urls).length > 1
          page_urls = page_urls.select { |url| url != navigation_url }
          page_urls = page_urls.select { |url| page.navigation(url).bucket.title == options[:use_alternate_urls][:bucket].to_s.downcase.gsub("_", " ") } if options[:use_alternate_urls][:bucket]

          if page_urls.length > 0 
            link_url = page_urls.first
          else
            link_url =  navigation_url
          end
        else
          link_url =  navigation_url
        end
      end
      
      link_options = page.open_new_window? ? {:target => "_blank"} : {}
      
      navigation_title = navigation.l10n_attribute(:title)
      navigation_title = page.l10n_attribute(:title) if navigation_title.blank?
      
      leaf = navigation_children(navigation).nil? or navigation_children(navigation).length == 0
      
      classes << "parent" unless leaf
      
      
    
      output += "<li class=\"#{classes.join(" ")}\">"
        output += link_to filter_page_title(navigation_title), link_url, link_options
        unless leaf or level >= options[:levels][:limit] or (options[:collapsed] and classes.include?("active") == false)
          output += "<ul>" + navigation_tree(navigation_children(navigation), options, navigation_url, level + 1) + "</ul>"
        end
      output += "</li>"

    end
    
    output
  end
  
  def filter_page_title(title)
    title.gsub("®", "<sup>®</sup>")
  end

  
end
