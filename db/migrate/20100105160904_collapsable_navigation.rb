class CollapsableNavigation < ActiveRecord::Migration
  def self.up
    add_column :navigations, :collapsed, :boolean, :default => false
  end

  def self.down
    remove_column :navigations, :collapsed
  end
end
