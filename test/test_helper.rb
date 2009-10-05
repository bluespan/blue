ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) +
                         "/rails_root/config/environment")
require 'test_help'

$: << File.expand_path(File.dirname(__FILE__) + '/..')
require 'blue'

gem 'thoughtbot-factory_girl'
require 'factory_girl'

Factory.define :admin_user_role do |role|
end


Factory.define :editor_user, :class => AdminUser do |u|
  u.firstname 'Admin'
  u.lastname  'User'
  u.admin_user_roles  [Factory.build(:admin_user_role, :admin_content => true)]
end



begin
  require 'redgreen'
rescue LoadError
end

begin
  require 'mocha'
rescue LoadError
end