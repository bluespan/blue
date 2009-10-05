class GlobalVerbiage < Content

  def self.[](title)
    title = title.to_s
    GlobalVerbiage.find_by_title(title) || GlobalVerbiage.new({:title => title})
  end

end