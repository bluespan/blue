# Include hook code here
require 'blue'

ActiveRecord::Base.send :include, Span::Blue::PageMethods