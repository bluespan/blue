class AddMultilingualContent < ActiveRecord::Migration
  def self.up
    add_column :content, :locale, :string, :default => "en"
  end

  def self.down
    remove_column :content, :locale
  end
end