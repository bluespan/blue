class AdminSession < Authlogic::Session::Base
  authenticate_with AdminUser
end