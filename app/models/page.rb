class Page < ActiveRecord::Base
  
  
  named_scope :published, lambda { |slug|  { :conditions => ["working_id is not ? and slug like ?", nil, slug], :order => "id DESC" } }
  named_scope :workings,  lambda { |*slug| { :conditions => ["working_id is ? and slug like ?", nil, slug.first || "%"] } }

  has_many    :navigations, :dependent => :destroy
  has_many    :content, :dependent => :destroy
  
  has_many    :published, :class_name => "Page", :foreign_key => :working_id, :order => "id DESC"
  has_one     :live,      :class_name => "Page", :foreign_key => :working_id, :order => "id DESC"
  belongs_to  :working,   :class_name => "Page", :foreign_key => :working_id
    
  validates_presence_of   :title, :message => "can't be blank"
  validates_uniqueness_of :slug,  :message => "must be unique", :scope => :working_id
  
  before_validation :generate_unique_slug!
   
  attr_accessor :body_id, :body_class
  cattr_accessor :types
  
  # acts_as_ferret :fields => {
  #                              :title => {:store => :yes}, 
  #                              :url => {:store => :yes}, 
  #                              :page_content => {:store => :yes}
  #                            },
  #                 :if => lambda { |page| page.published? && (not page.working.nil?) && page.working.live == page}
                  
  acts_as_commentable
               
  def verbiage(key, options = {})
    verbiage = content_hash[key] || Verbiage.new({:title => key, :page_id => id, :content => options[:default]})
    verbiage.content = options[:value]  if options.include?(:value)
    verbiage.save!                      if verbiage.content_changed?
    content_hash[key] = verbiage
  end
  
  def navigation(path)
    @navigation ||= {}
    @navigation[path] ||= (published? ? working.navigations : navigations).select do |navigation|
      navigation.url == path
    end[0]
  end

  def publish
    # Remove old published page if exists from Ferret Index
    # live.ferret_destroy if live

    published_page = clone
    
    # Disable Ferret while we save the page's content
    # published_page.disable_ferret(:index_when_finished) do 
    
      published_page.working_id = id
      published_page.save(false) # Don't run validations, we know it to be valid
    
      # Publish Content
      content_hash.each_value do |content_obj|
        content_obj.publish!({:page_id => published_page.id})
      end
      
      # Publish Comments
      comments.each do |comment|
        comment.commentable_id = published_page.id
      end
    
    # end
    
    published_page
  end
  
  def published?
    working_id != nil
  end
  
  def pending_publish?
    live.nil? || updated_at > live.updated_at
  end

  def generate_unique_slug!
    return self[:slug] unless self[:slug].blank?
    
    # StringExtensions method
    self[:slug] = self[:title].to_url 
    
    # Make sure slug is unique-like
    unless ( page = Page.workings(self[:slug]+"%").last({:select => "slug", :order => "slug"}) ).nil?
      incrementer = page.slug.match(/(-\d+)$/).to_a[1] || "-1"
      self[:slug] += incrementer.next
    end
  end
  
  def url
    urls(:first)
  end
  
  def urls(count = :all, options = {})
    url_array = []
    (published? ? working.navigations : navigations).each do |navigation|
      url_array << navigation.url
      return url_array[0] if count == :first
    end
    return "/#{slug}" if count == :first
    url_array << "/#{slug}"
  end

  
  def template
    sub_dir = self.class.to_s.split("::")[1].underscore
    @template = TemplateFile.find("/" + sub_dir + "/" + self[:template_file])
  end
  

  def display_name
    self.class.display_name
  end
  
  def css_class
    self.type.to_s.split("::")[1].underscore
  end
  
  def open_new_window?
    false
  end
  
  def page_content 
    value = ""
    content.each do |c|
      value += (c.content + " ").chop.gsub(/<\/?[^>]*>/, " ") + " "
    end
    value.chop
  end

  def content_hash
    @content_hash ||= Hash[*content.collect { |c| [c.title, c] }.flatten]
  end
  
  class << self
    
    def search (keywords, options = {})
      options = {:limit => 10, :page => 1, :lazy => [:title, :page_contents, :url]}.merge(options)
      options[:offset] = options[:limit].to_i * (options[:page].to_i - 1)
      current_page = options[:page]

      result = Page.find_with_ferret(keywords, options)

      returning WillPaginate::Collection.new(current_page, options[:limit], result.total_hits) do |pager|
        pager.replace result
        def pager.total_hits
          total_entries()
        end
      end
    end


    def templates
      templates = []

      sub_dir = self.to_s.split("::")[1].underscore

      Dir.new(BLUE_TEMPLATE_ROOT + "/" + sub_dir).each do |file|
        templates << TemplateFile.new(BLUE_TEMPLATE_ROOT + "/" + sub_dir + "/" + file, "r") unless file[/^\..*$/]
      end

      return templates
    end

    def display_name
      "Page"
    end
    
    def live(slug = nil)
      slug.nil? ? self.workings.find(:all, :include => :live).collect{|p| p.live}.compact : self.published(slug).first
    end

    def working(slug = nil)
      slug.nil? ? self.workings : self.workings(slug).first
    end

    def pending_publish
      self.working(nil).find(:all, :order => :title).delete_if do |page|
         not page.pending_publish?
      end
    end

    def publish_all
      published_pages = []
      self.pending_publish.each do |page|
        published_pages << page.publish
      end
      published_pages
    end
        
  end
  
end