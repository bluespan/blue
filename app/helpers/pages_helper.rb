module PagesHelper
  
  def verbiage(key, options = {}, &default_block)
    options = {:contentable => @page, :partial => "verbiage"}.merge(options)
    return if options[:contentable].nil?
    
    global_verbiage(key, options, &default_block)  
  end
  
  def global_verbiage(key, options = {}, &default_block)    
      options = {:partial => "global_verbiage", :admin => true, :editor => "wymeditor", :members_only => false}.merge(options)
      default_content = block_given? ? capture(&default_block) : nil
      
      if (options[:contentable].nil?)
        Span::Blue.locales.each do |locale|
          if GlobalVerbiage[key][locale.to_s].new_record?
            GlobalVerbiage[key][locale.to_s].content = default_content
            GlobalVerbiage[key][locale.to_s].members_only = options[:members_only]
            GlobalVerbiage[key][locale.to_s].save!
          end
        end
        verbiage = GlobalVerbiage[key][I18n.locale.to_s]
      else
        init_verbiage(key, options, default_content)
        verbiage = options[:contentable].verbiage[key.to_sym][I18n.locale.to_s]
        verbiage = options[:contentable].verbiage[key.to_sym][Span::Blue.locales.first.to_s] if verbiage.nil?
      end
      
      if logged_in? && options[:admin]
        concat render(:partial => "admin/verbiage/#{options[:partial]}", :object => verbiage, :locals => {:options => options})
      else
        concat verbiage.content unless verbiage.members_only? and member_logged_in? == false and logged_in? == false
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
    
    if top.is_a?(Navigation)
      @top = top
      url = "/#{top.page.slug}"
    else
      @top = Navigation.bookmark(top)
    end
    
    output =  "<ul id=\"#{options[:id]}\""
    output += " class=\"#{options[:class]}\"" if options[:class] 
    output += ">"
    output += navigation_tree(@top.children.slice(0..(options[:top_levels]-1)), options, url) unless @top.nil?
    output += "</ul>"
  end
  
  def breadcrumbs(options = {})
    options = {:navigation => @navigation, :delimiter => " / ", :link_current_page => true}.update(options)
    return if options[:navigation].nil?
    
    @navigation.self_and_ancestors.delete_if{|navigation| navigation.root? }.collect do |navigation|
      link_to navigation.page.l10n_attribute(:title), navigation.page.url, :class => (@page == navigation.page) ? "current" : ""
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
    return "" if @page.nil?
    " - #{@page.l10n_attribute(:title)}"
  end
  
  def working_page
    @working_page = @page.published? ? @page.working : @page
  end
  
  def search_highlite(result, field)
    (content = result.highlight(@search_query, :field => field, :num_excerpts => 2, :pre_tag => "<em>", :post_tag => "</em>")).blank? ? result.send(field).split(" ")[0..40].join(" ") : content
  end
  
  def embed_video(video, options = {})
    video.embed_html(options)
  end
  
  def video_paginate(options = {})
    options = {:page => 1, :include => {:page => :video}}.merge(options)
    @navigation.children.paginate(options)
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
      
      next if (navigation.display? == false && options[:force_display] == false) || page.nil?
      next if navigation.display_to_members_only? && member_logged_in? == false
      next if page.class == PageTypes::MemberSignInPage && member_logged_in? == true
      next if page.class == PageTypes::MemberSignInPage && @page.class == PageTypes::MemberSignInPage
      next if page.class == PageTypes::MemberSignOutPage && member_logged_in? == false
      
      if page.class == PageTypes::HomePage
        navigation_url = "/"
      else
        navigation_url = "#{url}/#{page.slug}"
      end
    
      classes = []
      classes << cycle(*options[:classes][level]) if options[:classes] && options[:classes][level]
      if @navigation
        classes << "active"   if @navigation.self_and_ancestors_cached.include?(navigation)
      end  
      classes << "current"  if page.id == @page.id
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
      
      navigation_title = navigation.title
      navigation_title = page.l10n_attribute(:title) if navigation_title.blank?
      
      output += "<li class=\"#{classes.join(" ")}\">"
        output += link_to filter_page_title(navigation_title), link_url, link_options
        unless navigation.leaf? or level >= options[:levels] or (options[:collapsed] and classes.include?("active") == false)
          output += "<ul>" + navigation_tree(navigation.children, options, navigation_url, level + 1) + "</ul>"
        end
      output += "</li>"

    end
    
    output
  end
  
  def filter_page_title(title)
    title.gsub("®", "<sup>®</sup>")
  end

  
end
