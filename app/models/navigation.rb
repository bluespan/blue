class Navigation < ActiveRecord::Base
  
  validates_presence_of :title, :unless => :has_a_page?
  
  acts_as_nested_set
  belongs_to :page #, :include => :live

  def slug
    self.title.downcase.gsub(" ", "_")
  end  
    
  def bucket
    root
  end
  
  def bucket?
    root?
  end
  
  def live
    page.live
  end
  
  def self_and_ancestors_cached
    @self_and_ancestors ||= self_and_ancestors#(:include => :page) 
  end
  
  def url
    final_url = ""
    self_and_ancestors_cached.each do |navigation|
      unless navigation.root?
        final_url += "/#{navigation.page.slug}"
      end
    end
    
    final_url
  end
  
  def published_page
    @published_page ||= page.find_by_sql
  end
  
  def self.bookmark(bookmark)
    self.find(:first, :conditions => {:title => bookmark.to_s.downcase.gsub("_", " ")})
  end
  
  def self.bucket(title)
    self.find(:first, :conditions => {:parent_id => nil, :title => title.downcase.to_s})
  end
  
  def self.buckets
    self.find(:all, :conditions => {:parent_id => nil}, :order => :lft)
  end
  
  def self.home
    @@home ||= self.bucket("home") || Navigation.create!(:title => "home")
  end
  
  private
  
  def has_a_page?
    self.page_id?
  end
  
end
