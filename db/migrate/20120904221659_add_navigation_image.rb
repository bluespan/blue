class AddNavigationImage < ActiveRecord::Migration
  def self.up
    add_column :navigations, :image_file_name, :string
    add_column :navigations, :image_content_type , :string
    add_column :navigations, :image_file_size    , :integer
    add_column :navigations, :image_updated_at, :datetime
  end

  def self.down
    remove_column :navigations, :image_file_name
    remove_column :navigations, :image_content_type
    remove_column :navigations, :image_file_size  
    remove_column :navigations, :image_updated_at
  end
end