class ModifyContentMakeCommon < ActiveRecord::Migration
  def self.up
    rename_column :content, :page_id, :contentable_id
    add_column :content, :contentable_type, :string, :default => "Page"
  end

  def self.down
    remove_column :content, :contentable_type
    rename_column :content, :contentable_id, :page_id
  end
end
