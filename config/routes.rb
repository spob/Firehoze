ActionController::Routing::Routes.draw do |map|


  map.resource  :account, :controller => "profiles"
#  map.resources :homes
  map.resources :profiles     
  map.resources :users
  map.resources :user_logons
  map.login 'login',   :controller => 'user_sessions', :action => 'new'  
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.resource  :user_session
  map.resources :passwords
  map.resources :password_resets
  map.resources :periodic_jobs, :member => { :rerun => :post }
  map.home 'home', :controller => 'videos', :action => 'index'
  map.resources :videos
           
  map.root :controller => "videos", :action => "index"
end
