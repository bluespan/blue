class NavigationDisplayInNavigation < ActiveRecord::Migration
  def self.up
    add_column :navigations, :display, :boolean, :default => true
  end

  def self.down
    remove_column :navigations, :display
  end
end
