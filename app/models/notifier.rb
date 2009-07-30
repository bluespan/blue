class Notifier < ActionMailer::Base
  
  def comment_notification(comment, params)
    recipients params[:recipients]
    subject    params[:subject]
    content_type "multipart/alternative"
    
    part :content_type => "text/html",
            :body => comment.comment
  end
  
end
