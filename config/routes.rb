ActionController::Routing::Routes.draw do |map|
  map.resources :discounts

  map.home 'home', :controller => 'lessons', :action => 'index'
  map.resource  :account, :controller => "profiles"
  map.resources :carts, :only => [ :show ]
  map.resources :credits
  map.resources :line_items, :only => [ :create, :destroy, :update ]
  map.resources :orders
  map.login 'login',   :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :profiles
  map.resources :passwords
  map.resources :password_resets
  map.resources :periodic_jobs, :member => { :rerun => :post }
  map.resources :skus, :has_many => :discounts, :shallow => true
  map.resource  :user_session, :only => [ :create, :destroy, :new ]
  map.resources :users
  map.resources :user_logons
  map.resources :lessons
  map.resources :registrations, :only => [ :new, :create ] do |registration|
    registration.resources :users, :only => [ :new, :create ]
  end


  map.current_cart 'cart', :controller => 'carts', :action => 'show', :id => 'current'
  map.root :controller => "lessons", :action => "index"
end
