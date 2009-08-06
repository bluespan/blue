class CreateVideos< ActiveRecord::Migration
  def self.up
      create_table :videos do |t|
        t.string :type
        t.string :title
        t.text :description
        t.references :page
        
        t.string :url
        t.string :clip_id
        t.text :duration_in_seconds
        t.string :thumbnail
        
        t.timestamps
      end

    end

    def self.down
      drop_table :videos
    end
end
