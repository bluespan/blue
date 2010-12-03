class ContentModule < Content

  has_many :pages, :through => :content_placements
  has_many :content_placements, :dependent => :destroy

  

  def self.[](title)
    title = title.to_s
    ContentModule.find_by_title(title) || ContentModule.new({:title => title})
  end

end