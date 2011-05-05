ActionController::Routing::Routes.draw do |map|
  
  map.namespace :admin do |admin|
    
    admin.root :controller => 'pages', :action => 'index'
    admin.resources :pages, :member => {:publish => :put, :typecast => :get}, :collection => {:publish_all => :put, :typecast => :get} do |pages|
      pages.resources :comments
      pages.resources :content_placements
    end
    
    admin.resources :publish, :controller => 'publish'
    admin.resources :verbiage do |verbiage|
      verbiage.resources :comments
    end

    admin.resources :global_verbiage do |global_verbiage|
      global_verbiage.resources :comments
    end
    
    admin.resources :content_modules

    admin.resources :external_links
    admin.resources :navigations, :collection => { :move => :put }
  
    admin.connect 'assets/viewer/:path', :controller => 'assets', :action => 'viewer', :path => /[A-Za-z0-9\-\/_\%\s\[\]]*/
    admin.connect 'assets/viewer/:path', :controller => 'assets', :action => 'show', :path => /[A-Za-z0-9\-\/_\.\%\s\[\]]*/
    admin.connect 'assets/:path/destroy', :controller => 'assets', :action => 'destroy', :path => /[A-Za-z0-9\-\/_\.\%\s\[\]]*/
    admin.connect 'assets/:path/destroy.:format', :controller => 'assets', :action => 'destroy', :path => /[A-Za-z0-9\-\/_\.\%\s\[\]]*/
    admin.connect 'assets/selector/:path', :controller => 'assets', :action => 'selector', :path => /[A-Za-z0-9\-\/_\%\s\[\]]*/
    admin.resources :assets,  :collection => { :viewer => :get, :selector => :get, :link => :get, :new_folder => :get, :create_folder => :post, :destroy => :delete }
  
    admin.resource :session, :member => {:view_live_site => :put}
    admin.resource :account, :controller => "admin_users"
    admin.resources :members, :controller => "members"
    admin.resource :membership, :controller => "membership"
    admin.resources :admin_users
  
    admin.connect 'publish/:action/:id/', :controller => 'publish'
    admin.connect 'publish/:action/:id/.:format', :controller => 'publish'
    
    admin.resources :videos
    
  end
  
  map.with_options :prefix_path => "admin/collections/" do |collection|
    collection.connect ':controller', :action => :index
    collection.connect ':controller/new', :action => :new
    collection.connect ':controller/create', :action => :create
    collection.connect ':controller/edit/:id', :action => :edit
    collection.connect ':controller/update/:id', :action => :update
    collection.connect ':controller/destroy/:id', :action => :destroy
  end
  map.connect ':controller', :action => :index, :prefix_path => "admin/collections/"
  map.connect ':controller', :action => :index, :prefix_path => "admin/collections/"
  map.connect ':controller/:action/:id', :prefix_path => "admin/collections/"
  
  
  map.resource :member_session, :member => {:signout => :get}

  map.connect 'sitemap.:format', :controller => 'sitemap', :action => 'show'

  map.connect ':ancestors/:slug', :controller => 'pages', :action => 'show', :ancestors => /[A-Za-z0-9\-\/_]*/
  map.connect ':slug', :controller => 'pages', :action => 'show'

  map.root :controller => 'pages', :action => 'home'

end