class Verbiage < Content
  
  acts_as_commentable
  after_save :touch_contentable
  
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
  
  def touch_contentable
    contentable.touch
  end
  
end