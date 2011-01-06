class AddBlueAdminRole < ActiveRecord::Migration
  def self.up
    add_column :admin_user_roles, :blue_admin, :boolean, :default => false
  end

  def self.down
    remove_column :admin_user_roles, :blue_admin
  end
end
