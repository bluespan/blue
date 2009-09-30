class AddOptionsToLinkPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :open_new_window, :boolean, :default => false
    #add_column :pages, :url, :string
  end

  def self.down
    remove_column :pages, :open_new_window
    #remove_column :pages, :url
  end
end
