module Admin::NavigationsHelper

  def bucket_tree(navigations, &block)
    navigations.each do |navigation|
      concat("<li class=\"page #{navigation.page.css_class}\"  id=\"navigation_#{navigation.id}\">#{capture(navigation, &block)}")
      unless navigation.leaf?
        concat("<ul>")
        bucket_tree(navigation.children, &block) 
        concat("</ul>")
      end
      concat("</li>")
    end
  end


end
