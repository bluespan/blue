class AddSerializedLocaleData < ActiveRecord::Migration
  def self.up
    add_column :pages, :locale_data, :text
    
    add_column :navigations, :locale_data, :text
    
  end

  def self.down
    remove_column :navigations, :locale_data
    remove_column :pages, :locale_data
  end
end