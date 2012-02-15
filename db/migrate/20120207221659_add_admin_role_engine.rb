class AddAdminRoleEngine < ActiveRecord::Migration
  def self.up
    add_column :admin_user_roles, :engine, :string, :default => "blue"
  end

  def self.down
    remove_column :admin_user_roles, :engine
  end
end