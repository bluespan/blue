class AddMembersOnlyPermissionToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :members_only, :boolean, :default => false
  end

  def self.down
    remove_column :pages, :members_only
  end
end
