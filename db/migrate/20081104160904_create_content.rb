class CreateContent < ActiveRecord::Migration
  def self.up
    create_table :content do |t|
      t.integer :page_id
      t.string  :type
      t.string  :title
      t.text    :content

      t.boolean   :published, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :content
  end
end
