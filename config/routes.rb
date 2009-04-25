ActionController::Routing::Routes.draw do |map|
  map.resource  :account, :controller => "profiles"
  map.resources :users
  map.resources :profiles, :member => { :edit_password => :get, :update_password => :put }
  map.resource  :user_session
  map.resources :password_resets
           
  map.root :controller => "user_sessions", :action => "new"
end
