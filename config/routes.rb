ActionController::Routing::Routes.draw do |map|
  map.resource  :account, :controller => "users"
  map.resources :users
  map.resource  :user_session
  map.resources :password_resets
           
  map.root :controller => "user_sessions", :action => "new"
end
