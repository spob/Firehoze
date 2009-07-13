ActionController::Routing::Routes.draw do |map|
  map.home 'home', :controller => 'lessons', :action => 'index'
  map.resource  :account, :controller => "profiles"
  map.resources :acquire_lessons, :only => [ :create, :new ]
  map.resources :carts, :only => [ :show ]
  map.resources :credits
  map.resources :gift_certificates,
                :member => { :redeem => :post, :give => :post, :pregive => :get, :confirm_give => :post }
  map.resources :helpfuls, :only => [ :create ]
  map.resources :lessons, :has_many => :reviews, :shallow => true,
                :member => { :watch => :get, :convert => :post, :rate => :post },
                :collection => { :conversion_notify => :put, :list => :get }
  map.resources :line_items, :only => [ :create, :destroy, :update ]
  map.resources :orders
  map.login 'login',   :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :profiles
  map.resources :passwords
  map.resources :password_resets
  map.resources :periodic_jobs, :member => { :rerun => :post }
  map.resources :store, :only => :show
  map.resources :skus, :has_many => :discounts, :shallow => true
  map.resource  :user_session, :only => [ :create, :destroy, :new ]
  map.resources :users
  map.resources :user_logons
  map.resources :registrations, :only => [ :new, :create ] do |registration|
    registration.resources :users, :only => [ :new, :create ]
  end
  map.current_cart 'cart', :controller => 'carts', :action => 'show', :id => 'current'
  map.root :controller => "lessons", :action => "index"
end
