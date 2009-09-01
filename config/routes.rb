ActionController::Routing::Routes.draw do |map|

  map.home 'home', :controller => 'home', :action => 'show'
  map.resources  :accounts,
                 :member => { :instructor_signup_wizard => :get,
                              :instructor_wizard_step1 => :get,
                              :instructor_wizard_step2 => :get,
                              :instructor_wizard_step3 => :get,
                              :instructor_wizard_step4 => :get,
                              :instructor_wizard_step5 => :get,
                              :clear_avatar => :post,
                              :update_avatar => :put,
                              :update_instructor => :put,
                              :update_instructor_wizard => :put,
                              :update_privacy => :put },
                 :collection => { :instructor_agreement => :get }
  map.resources :acquire_lessons, :only => [ :create, :new ]
  map.resources :carts, :only => [ :show ]
  map.resources :contact_users, :only => [ :create, :new ]
  map.resources :credits
  map.resources :flags, :only => [ :new, :create, :index, :show, :update, :edit ]
  map.resources :gift_certificates,
                :member => { :redeem => :post, :give => :post, :pregive => :get, :confirm_give => :post }
  map.resources :helpfuls, :only => [ :create ]
  map.resources :lessons, :has_many => :reviews, :shallow => true,
                :member => {
                        :convert => :post,
                        :lesson_notes => :get,
                        :rate => :post,
                        :watch => :get,
                        :unreject => :post },
                :collection => {
                        :conversion_notify => :put,
                        :list => :get,
                        :tabbed => :get,
                        :ajaxed => :get,
                        :list_admin => :get
                }
  map.resources :lessons, :has_many => :lesson_comments, :shallow => true,
                :member => {
                        :watch => :get,
                        :convert => :post,
                        :rate => :post },
                :collection => {
                        :conversion_notify => :put,
                        :list => :get
                }
  map.resources :line_items, :only => [ :create, :destroy, :update ]
  map.resources :orders
  map.login 'login',   :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :passwords
  map.resources :password_resets, :only => [ :create, :new, :edit, :update ]
  map.resources :payment_levels
  map.resources :per_pages, :collection => { :set => :post }, :only => [ :set ]
  map.resources :periodic_jobs, :member => { :rerun => :post }
  map.resources :store, :only => :show
  map.resources :skus, :has_many => :discounts, :shallow => true
  map.resource  :user_session, :only => [ :create, :destroy, :new ]
  map.resources :users,
                :member => { :show_admin => :get,
                             :clear_avatar => :post,
                             :reset_password => :post,
                             :update_privacy => :put,
                             :update_instructor => :put,
                             :update_avatar => :put,
                             :update_roles => :put },
                :collection => { :list => :get }
  map.resources :user_logons
  map.resources :wish_lists, :only => [ :create, :destroy ]
  map.resources :registrations, :only => [ :new, :create ] do |registration|
    registration.resources :users, :only => [ :new, :create ]
  end

  map.redirect '/admin', :controller => 'users', :action => 'list'
  map.current_cart 'cart', :controller => 'carts', :action => 'show', :id => 'current'
  map.root :controller => "lessons", :action => "index"

  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end