class MembersOnlyContent < ActiveRecord::Migration
  def self.up
    add_column :content, :members_only, :boolean, :default => false
  end

  def self.down
    remove_column :content, :members_only
  end
end
