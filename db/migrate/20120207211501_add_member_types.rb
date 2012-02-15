class AddMemberTypes < ActiveRecord::Migration
  def self.up
    add_column :members, :type, :string
  end

  def self.down
    remove_column :members, :type
  end
end