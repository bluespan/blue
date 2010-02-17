class Content < ActiveRecord::Base
  named_scope :published, :conditions => {:published => true}, :group => "contentable_id, title", :order => "created_at DESC"
  named_scope :working,   :conditions => {:published => false}
  
  
  belongs_to :contentable, :polymorphic => true
  
  def save_force_updated_at(updated_at, validations)
    class << self
      def record_timestamps; false; end
    end
    self[:updated_at] = updated_at
    save(validations)
    class << self
      remove_method :record_timestamps
    end
  end
end
