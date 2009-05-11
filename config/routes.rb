ActionController::Routing::Routes.draw do |map|
  map.resources :videos

  map.resources :user_logons

  map.resource  :account, :controller => "profiles"
  map.resources :homes
  map.resources :users
  map.resources :profiles
  map.resource  :user_session
  map.resources :passwords
  map.resources :password_resets
  map.resources :periodic_jobs, :member => { :rerun => :post }
           
  map.root :controller => "user_sessions", :action => "new"
end
