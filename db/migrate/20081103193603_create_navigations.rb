class CreateNavigations < ActiveRecord::Migration
  def self.up
    create_table :navigations do |t|
      t.string  :title
      t.integer :page_id
      
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      
      t.timestamps
    end
  end

  def self.down
    drop_table :navigations
  end
end
