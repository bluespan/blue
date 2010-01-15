class PlaceholderNavigation < ActiveRecord::Migration
  def self.up
    add_column :navigations, :placeholder, :boolean, :default => false
  end

  def self.down
    remove_column :navigations, :placeholder
  end
end
