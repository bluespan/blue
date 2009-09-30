class CreateAdminUserRoles < ActiveRecord::Migration
  def self.up
    create_table :admin_user_roles do |t|
      t.string :name
      
      t.boolean :publish,             :default => false
      t.boolean :admin_content,       :default => false
      t.boolean :admin_assets,        :default => false
      t.boolean :admin_admin_users,   :default => false
      t.boolean :comment,             :default => false
    end
    
    create_table :assigned_admin_user_roles do |t|
      t.integer :admin_user_id
      t.integer :admin_user_role_id
    end
    
    add_index :assigned_admin_user_roles, :admin_user_id
    
    # AdminUserRole.create({:name => "Administrator", :admin_admin_users => true})
    # AdminUserRole.create({:name => "Publisher", :publish => true})
    # AdminUserRole.create({:name => "Editor", :admin_content => true, :admin_assets => true})
    # AdminUserRole.create({:name => "Commentator", :comment => true})
  end

  def self.down
    remove_index :assigned_admin_user_roles, :admin_user_id
    drop_table :assigned_admin_user_roles
    drop_table :admin_user_roles
  end
end
