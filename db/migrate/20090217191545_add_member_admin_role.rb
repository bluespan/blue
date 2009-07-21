class AddMemberAdminRole < ActiveRecord::Migration
  def self.up
    add_column :admin_user_roles, :admin_membership, :boolean, :default => false
  end

  def self.down
    remove_column :admin_user_roles, :admin_membership
  end
end
