
map.namespace :admin do |admin|
  admin.root :controller => 'pages', :action => 'index'
  admin.resources :pages, :member => {:publish => :put, :typecast => :get}, :collection => {:publish_all => :put, :typecast => :get} do |pages|
    pages.resources :verbiage do |verbiage|
      verbiage.resources :comments
    end  
    pages.resources :comments
  end
  admin.resources :global_verbiage do |global_verbiage|
    global_verbiage.resources :comments
  end
  admin.resources :external_links
  admin.resources :navigations, :collection => { :move => :put }
  
  admin.connect 'assets/viewer/:path', :controller => 'assets', :action => 'viewer', :path => /[A-Za-z0-9\-\/_\%]*/
  admin.connect 'assets/viewer/:path', :controller => 'assets', :action => 'show', :path => /[A-Za-z0-9\-\/_\.\%]*/
  admin.connect 'assets/selector/:path', :controller => 'assets', :action => 'selector', :path => /[A-Za-z0-9\-\/_\%]*/
  admin.resources :assets,  :collection => { :viewer => :get, :selector => :get, :link => :get, :new_folder => :get, :create_folder => :post }
  
  admin.resource :session, :member => {:view_live_site => :put}
  admin.resource :account, :controller => "admin_users"
  admin.resource :membership, :controller => "membership"
  admin.resources :admin_users
  
  admin.connect 'publish/:action/:id/', :controller => 'publish'
  admin.connect 'publish/:action/:id/.:format', :controller => 'publish'
  admin.connect ':controller', :action => :index
  
end

map.resource :member_session, :member => {:signout => :get}

map.connect ':ancestors/:slug', :controller => 'pages', :action => 'show', :ancestors => /[A-Za-z0-9\-\/_]*/
map.connect ':slug', :controller => 'pages', :action => 'show'

map.root :controller => 'pages', :action => 'home'