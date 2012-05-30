require 'activerecord'

module Blue
  module Acts 
    module Collection

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_collection(options = {})  
                    
          extend Blue::Acts::Collection::SingletonMethods
          include Blue::Acts::Collection::InstanceMethods
          
          options = {:slugs => false}.merge(options)
          
          named_scope :newest, :order => "published_at DESC"
          named_scope :published, lambda { {:conditions => ["published_at <= ?", Time.now] } }
          
          
          if options[:slugs]
            auto_slug_field = "'#{options[:slugs]}'.intern"
          else
            auto_slug_field = "false"
          end
          
          class_eval <<-EOV
            def auto_slug_field
              #{auto_slug_field}
            end
          EOV
          
          before_validation :generate_unique_slug! if auto_slug_field
          
        end
        
      end
      
      # This module contains class methods
      module SingletonMethods
        def collection
          Page.workings.find(:first, :conditions => {:type => "Collection", :collects => self.name.tableize})
        end
        
        def view_paths
          c = self
          paths = ["app/views/#{c.name.tableize}"]
          while c.superclass and c.superclass != ActiveRecord::Base
             c = c.superclass
             paths << "app/views/#{c.name.tableize}"
          end
          paths
        end

        def find_collection_item(slug, options)
          begin
            item = self.column_names.include?("slug") ? self.find_by_slug(slug) : self.find(slug)
          rescue
            item = self.new if slug == "new"
          end
          item
        end
        
      end
      
      # This module contains instance methods
      module InstanceMethods  
        def collection
          @collection ||= Page.workings.find(:first, :conditions => {:type => "Collection", :collects => self.class.name.tableize})
        end
        
        def url(version = :live)
          collection.version(version).nil? ? "#" : "#{collection.version(version).url}/#{(self.slug)}"
        end  
        
        def display_title
          title
        end
        
        def template_file
          "show.html.erb"
        end
              
        def proxy_page(version = :live)
          @proxy_page ||= begin
            proxy = Proxy::Page::Item.new({:id => collection.id })
            exclude_attributes = [:id, :type, :url, :published]

            proxy.attributes.reject{|a, v| exclude_attributes.include?(a.to_sym) }.each do |a, v|
              proxy.send(:"#{a}=", self.send(:"#{a}") ) if self.respond_to?(a)
            end
            
            self.attributes.reject{|a, v| exclude_attributes.include?(a.to_sym) }.each do |a, v|
              proxy.send(:"#{a}=", v) if proxy.respond_to?(a)
            end

            proxy.item = self
            proxy.url = self.url(version)
            
            proxy
          end
        end

        def generate_unique_slug!
          return self[:slug] unless self.auto_slug_field != false and self[:slug].blank?
          
          # StringExtensions method
          self[:slug] = (self.send(self.auto_slug_field) || "").to_url 

          # Make sure slug is unique-like
          unless ( item = self.class.last(:conditions => ["slug like ?", self[:slug]], :select => "slug", :order => "slug") ).nil?
            incrementer = item.slug.match(/(-\d+)$/).to_a[1] || "-1"
            self[:slug] += incrementer.next
          end
        end
         
      end

      
    end
  end
end

ActiveRecord::Base.class_eval { include Blue::Acts::Collection }

