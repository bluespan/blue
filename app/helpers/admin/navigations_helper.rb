module Admin::NavigationsHelper

  def bucket_tree(navigations, &block)
    navigations.each do |navigation|
      concat("<li class=\"page\"  id=\"navigation_#{navigation.id}\">#{capture(navigation, &block)}")
      unless navigation.leaf?
        concat("<ul>")
        bucket_tree(navigation.children, &block) 
        concat("</ul>")
      end
      concat("</li>")
    end
  end


end
