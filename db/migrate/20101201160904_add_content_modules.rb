class AddContentModules < ActiveRecord::Migration
  def self.up
    create_table :content_placements, :force => true do |t|
      t.integer :content_id
      t.integer :page_id
      t.string  :title
      t.boolean :published, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :content_placements
  end
end
