class AssignedAdminUserRole < ActiveRecord::Base
  belongs_to :admin_user
  belongs_to :admin_user_role
end