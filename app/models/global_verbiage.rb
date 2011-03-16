class GlobalVerbiage < Content

  def self.[](title)
    title = title.to_s
    GlobalVerbiage.find_by_title(title) || GlobalVerbiage.new({:title => title})
  end
  
  def self.get(title, locale = nil)
    locale ||= Span::Blue.locales.first.to_s
    title, locale = title.to_s, locale.to_s
    GlobalVerbiage.find_by_title_and_locale(title, locale) || GlobalVerbiage.new({:title => title, :locale => locale})
  end


end