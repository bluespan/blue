class AssignedMemberRole < ActiveRecord::Base
  belongs_to :member_role
  belongs_to :assignable, :polymorphic => true
end