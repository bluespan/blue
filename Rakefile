require 'rake'
require 'rake/testtask'

namespace :test do
  Rake::TestTask.new(:basic => ["generator:cleanup", "generator:blue"]) do |task|
    task.libs << "lib"
    task.libs << "test"
    task.pattern = "test/models|controllers/*_test.rb"
    task.verbose = true
  end
  
  Rake::TestTask.new(:models) do |task|
    task.libs << "lib"
    task.libs << "test"
    task.pattern = "test/models/**/*_test.rb"
    task.verbose = true
  end
  
  Rake::TestTask.new(:controllers) do |task|
    task.libs << "lib"
    task.libs << "test"
    task.pattern = "test/controllers/**/*_test.rb"
    task.verbose = true
  end
  
  Rake::TestTask.new(:helpers) do |task|
    task.libs << "lib"
    task.libs << "test"
    task.pattern = "test/helpers/**/*_test.rb"
    task.verbose = true
  end
end

generators = %w(blue)

namespace :generator do
  desc "Cleans up the test app before running the generator"
  task :cleanup do

    FileList["test/rails_root/db/**/*"].each do |each| 
      FileUtils.rm_rf(each)
    end

    FileUtils.rm_rf("test/rails_root/vendor/plugins/blue")
    FileUtils.mkdir_p("test/rails_root/vendor/plugins")
    blue_root = File.expand_path(File.dirname(__FILE__))
    system("ln -s #{blue_root} test/rails_root/vendor/plugins/blue")
  end

  desc "Run the blue generator"
  task :blue do
    system "cd test/rails_root && rake blue:bootstrap && rake db:migrate db:test:prepare"
  end
end

desc "Run the test suite"
task :default => ['test:basic']