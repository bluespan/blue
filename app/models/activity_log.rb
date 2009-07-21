class ActivityLog
  
  def self.log(user, object, action, description)
    # ActivityLogEntry.create({:user_id => user.id, :object => object.class.to_s, :object_id => object.id,
    #                          :action => action.to_s, :description => description})
  end
  
end