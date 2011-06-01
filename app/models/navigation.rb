class Navigation < ActiveRecord::Base
  
  validates_presence_of :title, :unless => :has_a_page?
  
  acts_as_nested_set
  has_localized_data
  
  belongs_to :page #, :include => :live

  named_scope :with_page, :include => [:page => :live]

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
  
  def url(version = :live)
    final_url = ""
    self_and_ancestors_cached.each do |navigation|
      unless navigation.root?
        final_url += "/#{navigation.page.version(version).slug}"
      end
    end
    
    final_url
  end
  
  # def descendant_tree
  #    @descendant_tree ||= begin
  #        tree = {}
  #        tree[id] ||= []
  #        stack = []
  #        stack.push(id)
  #        stack_level = 0
  #      
  #        descendants.with_page.each do |d|
  #          while (d.level <= stack_level)
  #            stack_level = stack_level - 1
  #            stack.pop
  #          end
  #          
  #          tree[stack.last] << d
  #          tree[d.id] ||= []
  #        
  #          if (d.level > stack_level)
  #            stack_level = d.level
  #            stack.push(d.id)
  #          end
  #        end
  # 
  #      tree
  #    end
  #  end
  
  def descendant_tree
     @descendant_tree ||= begin
         tree = {}
         tree[id] ||= []
         stack = []
         stack.push(id)
         stack_level = 0
    
         descendants.with_page.each do |d|
           # determine level
           d_level = stack.index(d.parent_id) + 1
           
           while (d_level <= stack_level)
             stack_level = stack_level - 1
             stack.pop
           end

           tree[stack.last] << d
           tree[d.id] ||= []

           if (d_level > stack_level)
             stack_level = d_level
             stack.push(d.id)
           end
         end

       tree
     end
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
