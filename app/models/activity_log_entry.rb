class ActivityLogEntry < ActiveRecord::Base
  
  belongs_to :user
  
end
