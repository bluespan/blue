class Content < ActiveRecord::Base
  named_scope :published, :conditions => {:published => true}, :group => "contentable_id, title", :order => "created_at DESC"
  named_scope :working,   :conditions => {:published => false}
  
  
  belongs_to :contentable, :polymorphic => true
end
