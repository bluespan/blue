class Video < ActiveRecord::Base
  
  belongs_to :page
  
  def duration
    Time.at(duration_in_seconds.to_i).gmtime.strftime('%R:%S')
  end
  
end