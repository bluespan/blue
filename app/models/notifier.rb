class Notifier < ActionMailer::Base
  
  def comment_notification(recipient, comment)
    recipients recipient.email
    subject    "New Comment for Page: #{comment.commentable.title}"
    body       :user => recipient, :comment => comment
    content_type "multipart/alternative"
  end
  
end
