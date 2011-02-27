require 'activerecord'

module Blue
  module Acts 
    module Collection

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_collection(options = {})
         
          @@options = {:slugs => false}.merge(options)
          
          include Blue::Acts::Collection::InstanceMethods
          extend Blue::Acts::Collection::SingletonMethods
          
          named_scope :newest, :order => "published_at DESC"
          named_scope :published, lambda { {:conditions => ["published_at <= ?", Time.now] } }
          
          if @@options[:slugs]
            before_validation :generate_unique_slug!
            include Blue::Acts::Collection::Slug
          end
        end
        
      end
      
      # This module contains class methods
      module SingletonMethods
        def collection
          Page.workings.find(:first, :conditions => {:type => "Collection", :collects => self.name.tableize})
        end
      end
      
      # This module contains instance methods
      module InstanceMethods  
        def collection
          @collection ||= Page.workings.find(:first, :conditions => {:type => "Collection", :collects => self.class.name.tableize})
        end
        
        def url(version = :live)
          "#{collection.version(version).url}/#{(self.id)}"
        end  
        
        def template_file
          "show.html.erb"
        end
              
        def proxy_page
          @proxy_page ||= begin
            proxy = Proxy::Page::Item.new({:id => collection.id })
            exclude_attributes = [:id, :type]

            proxy.attributes.reject{|a, v| exclude_attributes.include?(a.to_sym) }.each do |a, v|
              proxy.send(:"#{a}=", self.send(:"#{a}") ) if self.respond_to?(a)
            end
            
            self.attributes.reject{|a, v| exclude_attributes.include?(a.to_sym) }.each do |a, v|
              proxy.send(:"#{a}=", v) if proxy.respond_to?(a)
            end

            proxy.item = self
            
            proxy
          end
        end

         
      end
      
      module Slug
        def generate_unique_slug!
          return self[:slug] unless self[:slug].blank?

          # StringExtensions method
          self[:slug] = (self[:title] || "").to_url 

          # Make sure slug is unique-like
          unless ( item = self.class.find_by_slug(:last, :conditions => ["slug like ?", self[:slug]], :select => "slug", :order => "slug") ).nil?
            incrementer = page.slug.match(/(-\d+)$/).to_a[1] || "-1"
            self[:slug] += incrementer.next
          end
        end
      end
      
    end
  end
end

ActiveRecord::Base.send(:include, Blue::Acts::Collection)
