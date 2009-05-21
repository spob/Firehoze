ActionController::Routing::Routes.draw do |map|
  map.home 'home', :controller => 'videos', :action => 'index'
  map.resource  :account, :controller => "profiles"
  map.resources :credits
  map.resources :users
  map.resources :user_logons
  map.login 'login',   :controller => 'user_sessions', :action => 'new'  
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :profiles
  map.resources :passwords
  map.resources :password_resets
  map.resources :periodic_jobs, :member => { :rerun => :post }
  map.resources :skus
  map.resource  :user_session
  map.resources :videos
           
  map.root :controller => "videos", :action => "index"
end
