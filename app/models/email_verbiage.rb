class EmailVerbiage < Content

  def self.[](title)
    EmailVerbiage.find_by_title(title) || EmailVerbiage.new({:title => title})
  end

end