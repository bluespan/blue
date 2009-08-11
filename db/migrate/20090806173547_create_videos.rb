class CreateVideos< ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :type
      t.string :title
      t.text :description
      
      t.string :url
      t.string :clip_id
      t.text :duration_in_seconds
      t.string :thumbnail
      
      t.timestamps
    end

    add_column :pages, :video_id, :integer
  end

  def self.down
    remove_column :pages, :video_id
    drop_table :videos
  end
end
