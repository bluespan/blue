class CreateExternalLinks < ActiveRecord::Migration
  def self.up
    add_column :pages, :type, :string
    add_column :pages, :url, :string
  end

  def self.down
    remove_column :pages, :url
    remove_column :pages, :type
  end
end
