ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) +
                         "/rails_root/config/environment")
require 'test_help'

$: << File.expand_path(File.dirname(__FILE__) + '/..')
require 'blue'

begin
  require 'redgreen'
rescue LoadError
end
