class BlueCollectionGenerator < Rails::Generator::NamedBase
  attr_reader   :controller_name,
                :model_name,
                :name
  attr_accessor :attributes

  def initialize(runtime_args, runtime_options = {})
    super
    @name = runtime_args.first.downcase.underscore.pluralize
    @controller_name = @name.capitalize
    @model_name = @name.singularize.capitalize
    @model_name = @name.singularize.capitalize
    @attributes = []

    runtime_args[1..-1].each do |arg|
      if arg.include? ':'
        @attributes << Rails::Generator::GeneratedAttribute.new(*arg.split(":"))
      end
    end
  end

  def manifest
    record do |m|
      m.directory("app/controllers/admin/collections")
      m.template('admin_controller.rb.erb', "app/controllers/admin/collections/#{name.downcase.underscore.pluralize}_controller.rb")
      m.template('model.rb.erb', "app/models/#{name.downcase.underscore.singularize}.rb")
      m.migration_template("migration.rb.erb", "db/migrate", :migration_file_name => "create_#{name.underscore.pluralize}")

      m.directory(File.join('app/views', name.downcase.underscore.pluralize))
      for action in %w[ index show ]
        m.template(
          "view_#{action}.html.erb",
          File.join('app/views', name.downcase.underscore.pluralize, "#{action}.html.erb")
        )
      end
      
      
      m.directory(File.join('app/views/admin/collections/', name.downcase.underscore.pluralize))
      m.template('admin/view_form.html.erb', "app/views/admin/collections/#{name.downcase.underscore.pluralize}/_form.html.erb")
    end
  end
  
  protected
    def banner
      "Usage: #{$0} blue_collection CollectionName" 
    end
end