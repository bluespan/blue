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
  
  desc "Bootstrap your application for using blue"
  task :bootstrap => [:"bootstrap:link:assets", :"bootstrap:copy:migrations", :"bootstrap:copy:configs"]
  
  namespace :bootstrap do
    
    namespace :link do
      desc "Link blue assets to the public assets"
      task :assets do
        asset_linked = false
        print "Linking assets... "
        ["javascripts", "stylesheets", "images"].each do |asset|
          asset_blue = "#{RAILS_ROOT}/vendor/plugins/blue/assets/#{asset}"
          asset_link = "#{RAILS_ROOT}/public/#{asset}/blue"
          unless File.exist?(asset_link)
            asset_linked = true
            print "#{asset}... "
            File.symlink(asset_blue, asset_link) 
          end
        end
      
        puts asset_linked ?  "done." : "assets already linked."
      end
    end

    namespace :copy do
      desc "Copy blue migrations"
      task :migrations do
        print "Copying migrations... "
        FileUtils.mkdir_p "#{RAILS_ROOT}/db/migrate"
        FileList["#{RAILS_ROOT}/vendor/plugins/blue/db/migrate/*"].each do |source|
            FileUtils.cp_r source, source.gsub("/vendor/plugins/blue", "")
        end
        puts "done."
      end
    
      desc "Copy configs"
      task :configs do
        print "Copying configs... "
        FileList["#{RAILS_ROOT}/vendor/plugins/blue/config/environment.rb"].each do |source|
            print "#{source.gsub("/vendor/plugins/blue", "").gsub(RAILS_ROOT,"")}... "
            FileUtils.cp_r source, source.gsub("/vendor/plugins/blue", "")
        end
        puts "done."
      end
    end
  end
  
  namespace :create do
    desc "Create a default admin"
    task (:admin => :admin_roles) do
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
    task (:admin_roles => :environment) do
      AdminUserRole.create({:name => "Administrator", :admin_admin_users => true})
      AdminUserRole.create({:name => "Publisher", :publish => true})
      AdminUserRole.create({:name => "Editor", :admin_content => true, :admin_assets => true})
      AdminUserRole.create({:name => "Commentator", :comment => true})
    end
  end
  
end