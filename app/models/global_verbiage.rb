class GlobalVerbiage < Content

  def self.[](title)
    GlobalVerbiage.find_by_title(title) || GlobalVerbiage.new({:title => title})
  end

end