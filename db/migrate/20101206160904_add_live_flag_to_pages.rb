class AddLiveFlagToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :is_live, :boolean, :default => false
    
    Page.workings.find(:all).collect{|p| p.published.first}.compact.each { |page| page.update_attribute(:is_live, true)}
    
  end

  def self.down
    remove_column :pages, :is_live
  end
end