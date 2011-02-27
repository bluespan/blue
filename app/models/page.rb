class Page < ActiveRecord::Base
  
  
  named_scope :published, lambda { |slug|  { :conditions => ["working_id is not ? and slug like ?", nil, slug], :order => "id DESC" } }
  named_scope :workings,  lambda { |*slug| { :conditions => ["working_id is ? and slug like ?", nil, slug.first || "%"] } }
  named_scope :live,  :conditions => {:is_live => true}

  has_many    :navigations, :dependent => :destroy
  has_many    :content, :dependent => :destroy
  
  
  has_many    :content_placements
  has_many    :content_modules, :through => :content_placements
  
  has_many    :published, :class_name => "Page", :foreign_key => :working_id, :order => "id DESC"
  has_one     :live,      :class_name => "Page", :foreign_key => :working_id, :order => "id DESC"
  belongs_to  :working,   :class_name => "Page", :foreign_key => :working_id
    
  validates_presence_of   :title, :message => "can't be blank"
  #validates_uniqueness_of :slug,  :message => "must be unique", :scope => :working_id, :if => Proc.new { |page| page.working_id.nil? }

  
  before_validation :generate_unique_slug!
   
  attr_accessor :body_id, :body_class
  cattr_accessor :types, :allow_ssl
  
  
  # acts_as_ferret :fields => {
  #                              :title => {:store => :yes}, 
  #                              :url => {:store => :yes}, 
  #                              :page_content => {:store => :yes}
  #                            },
  #                 :if => lambda { |page| page.published? && (not page.working.nil?) && page.working.live == page}
                  
  acts_as_commentable
  acts_as_contentable
  has_localized_data
       
  def navigation(path)
    @navigation ||= {}
    @navigation[path] ||= (is_live? ? version(:working).navigations : navigations).select do |navigation|
      navigation.url(is_live? ? :live : :working) == path
    end[0]
  end

  def publish
    published.live.each {|p| p.update_attribute("is_live", false)}
    published_page = clone
    published_page.working_id = id
    published_page.is_live = true
    published_page.save(false) # Don't run validations, we know it to be valid
  
    # Publish Content
    content.each do |c|
      c.publish!({:contentable_id => published_page.id})
    end
    
    # Publish Content Placements
    content_placements.each do |p|
      p.publish!({:page_id => published_page.id})
    end
    
    # Publish Comments
    comments.each do |comment|
      comment.commentable_id = published_page.id
    end

    published_page
  end
  
  def version(state)
    case state
    when :live
      return is_live? ? self : version(:working).live
    when :working
      return is_working? ? self : self.working
    else
      return self
    end
  end
  
  def revert_to_live 
    
    if live    
      # Revert Content
      live.content.each do |live_content|
        content.each do |content|
          if content.title == live_content.title
            content.content = live_content.content
            content.save_force_updated_at live_content.updated_at, false
          end
        end
      end
      
      # Revert Placements
      content_placements.each do |p|
        p.destroy
      end
      live.content_placements.each do |p|
        p.publish!({:page_id => id, :published => false})
      end
    
      self[:title] = live.title
      self[:slug] = live.slug
      self[:template_file] = live.template_file
      self[:meta_description] = live.meta_description
      self[:meta_keywords] = live.meta_keywords
      self[:type] = live.type
      self[:url] = live.url
      self[:members_only] = live.members_only
      self[:open_new_window] = live.open_new_window
      self[:video_id] = live.video_id
      self[:require_ssl] = live.require_ssl

      save_force_updated_at live.updated_at, false
    else
      content.each {|c| c.destroy }
    end
  end
  
  def save_force_updated_at(updated_at, validations = true)
    class << self
      def record_timestamps; false; end
    end
    self[:updated_at] = updated_at
    save(validations)
    class << self
      remove_method :record_timestamps
    end
  end
  
  def published?
    working_id != nil
  end
  
  def is_working?
    working_id == nil
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
    (published? ? version(:working).navigations : navigations).each do |navigation|
      url_array << navigation.url(published? ? :live : :working)
      return url_array[0] if count == :first
    end
    return "/#{slug}" if count == :first
    url_array << "/#{slug}"
  end

  
  def template
    sub_dir = self.class.to_s.split("::")[1].underscore
    @template = TemplateFile.find("/" + sub_dir + "/" + self[:template_file]) unless self[:template_file].blank?
  end

  def display_name
    self.class.display_name
  end
  
  def css_class
    self.class.css_class
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

  def class_type=(value)
    self[:type] = value
  end

  def class_type
    return self[:type]
  end 

  class << self
    
    def css_class
      self.to_s.split("::")[1].underscore
    end
    
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
    
    # def live(slug = nil)
    #   slug.nil? ? self.workings.find(:all, :include => :live).collect{|p| p.live}.compact : self.published(slug).first
    # end

    def load_from_url(slug = nil, ancestors = "")
      return self.workings if slug.nil?


      pages = Page.find(:all,  :conditions => ["slug like ?", slug], :order => "id DESC")

      pages = pages.select do |page|
        page.is_live? or page.is_working?
      end

      pages.each do |page|
        page.urls.each do |url|
          return page if ancestors+"/"+slug == url 
        end
      end

      return pages.first
    end
      
    def working(slug = nil, ancestors = "")
      return (self.workings || self) if slug.nil?
      
      pages = self.workings(slug)
      return pages.first if pages.length == 0 || ancestors.blank?
      
      pages.each do |page|
        page.urls.each do |url|
          return page if ancestors+"/"+slug == url
        end
      end
      
      return pages.first
    end

    def pending_publish
      self.workings.find(:all, :order => :title).delete_if do |page|
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
    
    def destroyable?
      true
    end
        
  end
  
end