def file_starts_with?(file, string)
  return false unless File.exist?(file)

  contents = ''
  File.open(file, 'r') do |f|
   contents = f.sysread(20)
  end
  
  contents.include?(string)
end


namespace :deploy do
  namespace :migrate do 
    desc "Migrate plugins"
    task :plugins => :environment do
      Engines.plugins.each do |plugin|
        next unless File.exist? plugin.migration_directory
        puts "Migrating plugin #{plugin.name} ..."
        plugin.migrate
      end
    end
  end
end

namespace :blue do
  
  desc "Bootstrap your application for using blue"
  task :bootstrap => [:"bootstrap:link:assets", :"bootstrap:sync", :"bootstrap:copy:configs", :"bootstrap:copy:initial_templates"] do
    if File.exist?("public/index.html")
      puts "Removing public/index.html"
      File.unlink "public/index.html" 
    end
  end
  
  namespace :bootstrap do
    
    namespace :link do
      desc "Link blue assets to the public assets"
      task :assets do
        print "** Linking assets... "
        ["javascripts", "stylesheets", "images"].each do |asset|
          asset_blue = "../../vendor/plugins/blue/assets/#{asset}"
          asset_link = "public/#{asset}/blue"
          unless File.exist?(asset_link)
            print "#{asset}... "
            File.symlink(asset_blue, asset_link) 
          end
        end
        
        puts "done."
      
        print "** Creating public asset directories... "
        ["images", "documents"].each do |directory|
          print "#{directory}... "
          mkdir_p "public/assets/#{directory}"
        end
        puts "done."
      end
    end
    
    desc "Updates blue files within your application"
    task :sync => [:"sync:migrations"]
    namespace :sync do 
      desc "Sync blue migrations"
      task :migrations do 
        puts "** Syncing migrations..."
        system "rsync -ruv vendor/plugins/blue/db/migrate db"
        puts "** Done syncing migrations."
      end
    end

    namespace :copy do
    
      desc "Copy configs"
      task :configs do
        print "** Copying configs... "
        FileList["vendor/plugins/blue/config/environment.rb", "vendor/plugins/blue/config/initializers/blue.rb"].each do |source|
            target = source.gsub("vendor/plugins/blue", "")
            unless file_starts_with?(RAILS_ROOT+target, "# modified by blue")
              print "#{target}... "
              FileUtils.cp_r source, RAILS_ROOT+target
            end
        end
        puts "done."
      end
      
      desc "Initial Templates"
      task :initial_templates do
        print "** Copying initial templates... "
        mkdir_p("app/views/pages")
        FileList["vendor/plugins/blue/app/views/pages/home_page/home.html.erb"].each do |source|
            target = source.gsub("vendor/plugins/blue/", "")
            unless File.exist?(target)
              mkdir_p(target.gsub(/\/[^\/]+$/, ""))
              FileUtils.cp_r source, target
              print "#{target}... "
            end
        end
        puts "done."
      end
    end
  end
  
  namespace :create do
    desc "Create a default admin"
    task (:admin, :force, :needs => [:admin_roles]) do |t, args|
      if AdminUser.count == 0 or args.force
        AdminUser.find_by_login("admin").destroy if AdminUser.count > 0
        
        chars = ("a".."z").to_a + ("1".."9").to_a 
        newpass = Array.new(8, '').collect{chars[rand(chars.size)]}.join
        
        admin = AdminUser.create!({:login => "admin", :password => newpass, :password_confirmation => newpass, :firstname => "Admin", :lastname => "User", :email => "admin@localhost.com"})        
        adminstrator_role = AdminUserRole.find_by_name("Administrator")
        blue_admin = AdminUserRole.find_by_name("Blue Admin")
        admin.admin_user_roles << adminstrator_role
        admin.admin_user_roles << blue_admin
        puts "Admin Created - u: admin, p: #{newpass}"
      else
        puts "Admin already exists"
      end
    end
    
    desc "Create user admin roles"
    task (:admin_roles => :environment) do
      AdminUserRole.create({:name => "Administrator", :admin_admin_users => true, :admin_membership => true})
      AdminUserRole.create({:name => "Publisher", :publish => true})
      AdminUserRole.create({:name => "Editor", :admin_content => true, :admin_assets => true})
      AdminUserRole.create({:name => "Commentator", :comment => true})
      AdminUserRole.create({:name => "Blue Admin", :blue_admin => true})
    end
  end
  
end