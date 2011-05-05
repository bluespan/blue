class AddExtraCodeToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :extra_code, :text
  end

  def self.down
    remove_column :pages, :extra_code
  end
end
