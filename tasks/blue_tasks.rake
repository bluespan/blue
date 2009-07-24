namespace :deploy do
  namespace :migrate do 
    desc "Migrate plugins"
    task :plugins => :environment do
      Engines.plugins.each do |plugin|
        next unless File.exists? plugin.migration_directory
        puts "Migrating plugin #{plugin.name} ..."
        plugin.migrate
      end
    end
  end
end

namespace :blue do
  namespace :create do
    desc "Create a default admin"
    task (:admin => :roles) do
      if AdminUser.count == 0
        chars = ("a".."z").to_a + ("1".."9").to_a 
        newpass = Array.new(8, '').collect{chars[rand(chars.size)]}.join
        
        admin = AdminUser.create!({:login => "admin", :password => newpass, :password_confirmation => newpass, :firstname => "Admin", :lastname => "User", :email => "admin@localhost.com"})        
        adminstrator_role = AdminUserRole.find_by_name("Administrator")
        admin.admin_user_roles << adminstrator_role
        puts "Admin Created - u: admin, p: #{newpass}"
      else
        puts "Admin already exists"
      end
    end
    
    desc "Create user admin roles"
    task (:roles => :environment) do
      AdminUserRole.create({:name => "Administrator", :admin_admin_users => true})
      AdminUserRole.create({:name => "Publisher", :publish => true})
      AdminUserRole.create({:name => "Editor", :admin_content => true, :admin_assets => true})
      AdminUserRole.create({:name => "Commentator", :comment => true})
    end
  end
  
  namespace :transform do
    desc "Transform all pages to sub pages"
    task (:pages_to_subpages => :environment) do
      puts "Transforming pages to sub pages"
      page_count = 0
      Page.find(:all).each do |page|
        if page.class == Page
          page.type = "PageTypes::SubPage"
          page.save
          page_count += 1
        end
      end
      puts "Transformed #{page_count} pages"
    end
    
  end
end