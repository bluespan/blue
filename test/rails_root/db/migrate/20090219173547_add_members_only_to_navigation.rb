class AddMembersOnlyToNavigation < ActiveRecord::Migration
  def self.up
    add_column :navigations, :display_to_members_only, :boolean, :default => false
  end

  def self.down
    remove_column :navigations, :display_to_members_only
  end
end
