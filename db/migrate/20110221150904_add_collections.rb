class AddCollections < ActiveRecord::Migration
  def self.up
    add_column :pages, :collects, :string
  end

  def self.down
    remove_column :pages, :collects 
  end
end