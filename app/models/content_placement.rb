class ContentPlacement < ActiveRecord::Base
  belongs_to :page
  belongs_to :content
  
  after_save :set_page_to_pending_publishing
  
  def publish!(options = {})
    published_placement = clone
    published_placement.attributes = published_placement.attributes.update({:published => true}.update(options))
    published_placement.save!
  end
  
  def set_page_to_pending_publishing
    page.touch
  end
end