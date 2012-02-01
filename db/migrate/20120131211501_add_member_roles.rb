class AddMemberRoles < ActiveRecord::Migration
  def self.up
    create_table :member_roles do |t|
      t.string :name
    end
    
    create_table :assigned_member_roles do |t|
      t.integer :assignable_id
      t.string  :assignable_type
      t.integer :member_role_id
    end
    
    add_index :assigned_member_roles, :member_role_id
    add_index :assigned_member_roles, [:assignable_id, :assignable_type]
    
  end

  def self.down
    #remove_column :members, :name
    drop_table :assigned_member_roles
    drop_table :member_roles
  end
end