class Member < ActiveRecord::Base
  acts_as_authentic :session_class => "MemberSession"
end
