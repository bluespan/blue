class ModifyPageRequireSsl < ActiveRecord::Migration
  def self.up
    add_column :pages, :require_ssl, :boolean, :default => false
  end

  def self.down
    remove_column :pages, :require_ssl
  end
end
