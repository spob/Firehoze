ActionController::Routing::Routes.draw do |map|
  map.resources :user_logons

  map.resource  :account, :controller => "profiles"
  map.resources :homes
  map.resources :users
  map.resources :profiles
  map.resource  :user_session
  map.resources :passwords
  map.resources :password_resets
           
  map.root :controller => "user_sessions", :action => "new"
end
