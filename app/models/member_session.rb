class MemberSession < Authlogic::Session::Base
  authenticate_with Member
end