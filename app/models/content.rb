class Content < ActiveRecord::Base
  
  named_scope :published, :conditions => {:published => true}, :group => "page_id, title", :order => "created_at DESC"
  named_scope :working,   :conditions => {:published => false}
  
  acts_as_commentable
  
  belongs_to  :page
  
  after_save :touch_page
  
  def publish!(options = {})
    published_content = clone
    published_content.attributes = published_content.attributes.update({:published => true}.update(options))
    published_content.save!
    
    # Publish Comments
    comments.each do |comment|
      comment.commentable_id = published_content.id
    end
  end

  private
  
  def touch_page
    page.updated_at = Time.now
    page.save
  end

end
