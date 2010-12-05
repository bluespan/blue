class Tableless < ActiveRecord::Base

  # Override the save method to prevent exceptions.
  def save(validate = true)
    validate ? valid? : true
  end
  
  class << self
    def table_name
      self.name.tableize
    end
    
    def columns
      @columns ||= [];
    end
    
    def column(name, sql_type = nil, default = nil, null = true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
    end
  end
end