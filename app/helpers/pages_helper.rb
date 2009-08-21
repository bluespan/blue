module PagesHelper
  
  def verbiage(key, options = {}, &default_block)
    options = {:page => @page, :partial => "verbiage"}.merge(options)
    return if options[:page].nil?
    
    global_verbiage(key, options, &default_block)  
  end
  
  def global_verbiage(key, options = {}, &default_block)    
      options = {:partial => "global_verbiage"}.merge(options)
      key = key.to_s
      default_content = block_given? ? capture(&default_block) : nil
      
      if (options[:page].nil?)
        verbiage = GlobalVerbiage[key]
        if verbiage.new_record?
          verbiage.content = default_content
          verbiage.save!
        end
      else
        verbiage = options[:page].verbiage(key, :default => default_content)
      end
      
      if logged_in?
        concat render(:partial => "admin/pages/#{options[:partial]}", :object => verbiage)
      else
        concat verbiage.content
      end
  end
  
  def navigation(top, options = {})
    options = {:levels => 9999, :top_levels => 9999, :id => "#{top.to_s}_navigation", :collapsed => false}.update(options)
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
      link_to navigation.page.title, navigation.page.url, :class => (@page == navigation.page) ? "current" : ""
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
    " - #{@page.title}"
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
  def navigation_tree(navigations, options = {}, url = "", level = 1)
    output = ""
    
    navigations.each do |navigation|
      
      page = live_or_working navigation.page
      
      next unless navigation.display? && (not page.nil?)
      next if navigation.display_to_members_only? && member_logged_in? == false
      next if page.class == PageTypes::MemberSignInPage && member_logged_in? == true
      next if page.class == PageTypes::MemberSignInPage && @page.class == PageTypes::MemberSignInPage
      next if page.class == PageTypes::MemberSignOutPage && member_logged_in? == false
      
      navigation_url = "#{url}/#{page.slug}"
    
      classes = []
      classes << cycle(*options[:classes][level]) if options[:classes] && options[:classes][level]
      if @navigation
        classes << "active"   if @navigation.self_and_ancestors_cached.include?(navigation)
        classes << "current"  if page == @page
      end  
      classes << "first"  if navigation == navigations.first
      classes << "last"   if navigation == navigations.last
      classes << page.slug.underscore
    
      link_url = page.respond_to?(:link) ? page.link : navigation_url
      link_options = page.open_new_window? ? {:target => "_blank"} : {}
      
      output += "<li class=\"#{classes.join(" ")}\">"
        output += link_to filter_page_title(page.title), link_url, link_options
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
