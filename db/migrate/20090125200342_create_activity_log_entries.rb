class CreateActivityLogEntries < ActiveRecord::Migration
  def self.up
    create_table :activity_log_entries do |t|
      t.integer   :user_id
      t.string    :object
      t.integer   :object_id
      t.string    :action
      t.string    :description
      t.datetime  :created_at
    end
  end

  def self.down
    drop_table :activity_log_entries
  end
end
