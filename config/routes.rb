ActionController::Routing::Routes.draw do |map|
  map.resources :discounts

  map.home 'home', :controller => 'videos', :action => 'index'
  map.resource  :account, :controller => "profiles"
  map.resources :carts
  map.resources :credits
  map.resources :line_items
  map.resources :orders
  map.login 'login',   :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :profiles
  map.resources :passwords
  map.resources :password_resets
  map.resources :periodic_jobs, :member => { :rerun => :post }
  map.resources :skus
  map.resource  :user_session
  map.resources :users
  map.resources :user_logons
  map.resources :videos

  map.current_cart 'cart', :controller => 'carts', :action => 'show', :id => 'current'
  map.root :controller => "videos", :action => "index"
end
