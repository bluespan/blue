class AddLiveFlagToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :is_live, :boolean, :default => false
    
    Page.workings.find(:all).collect{|p| p.published.first}.compact.each do |page| 
      page.is_live = true #({:is_live => true })}
      page.save_force_updated_at(page.updated_at)
    end

  end

  def self.down
    remove_column :pages, :is_live
  end
end