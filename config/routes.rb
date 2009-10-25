ActionController::Routing::Routes.draw do |map|

  map.home 'home', :controller => 'home', :action => 'show'
  map.resources :accounts,
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
  map.resources :admin_consoles, :only => [ :index ]
  map.resources :carts, :only => [ :show ]
  map.resources :categories, :collection => { :explode => :post, :list_admin => :get }
  map.resources :contact_users, :only => [ :create, :new ]
  map.resources :credits
  map.resources :flags, :only => [ :new, :create, :index, :show, :update, :edit ]
  map.resources :gift_certificates,
                :collection => { :list_admin => :get },
                :member => { :redeem => :post,
                             :give => :post,
                             :pregive => :get,
                             :confirm_give => :post }
  map.resources :grant_gift_certificates, :only => [ :create, :new ]
  map.resources :groups
  map.resources :group_invitations, :only => [ :create, :new ]
  map.resources :group_members, :only => [ :create, :destroy ],
                :member => { :remove => :delete, :promote => :post, :demote => :post }
  map.resources :helpfuls, :only => [ :create ]
  map.resources :instructor_follows, :only => [ :create, :destroy ]
  map.resources :lessons, :has_many => :reviews, :shallow => true,
                :member => {
                        :convert => :post,
                        :lesson_notes => :get,
                        :rate => :post,
                        :watch => :get,
                        :unreject => :post
                },
                :collection => {
                        :conversion_notify => :put,
                        :list => :get,
                        :tabbed => :get,
                        :ajaxed => :get,
                        :list_admin => :get,
                        :tagged_with => :get,
                        :search => :get,
                        :advanced_search => :get,
                        :perform_advanced_search => :get
                }
  map.resources :lessons, :has_many => :lesson_comments, :shallow => true,
                :member => {
                        :watch => :get,
                        :convert => :post,
                        :rate => :post
                },
                :collection => {
                        :conversion_notify => :put,
                        :list => :get,
                        :search => :get
                }
  map.resources :lessons, :has_many => :lesson_attachments, :shallow => true
  map.resources :line_items, :only => [ :create, :destroy, :update ]
  map.resources :orders
  map.login 'login',   :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :passwords
  map.resources :password_resets, :only => [ :create, :new, :edit, :update ]
  map.resources :payment_levels
  map.resources :payments, :member => { :show_unpaid => :get,
                                        :list => :get },
                :only => [:index, :show, :show_unpaid, :create]
  map.resources :per_pages, :collection => { :set => :post }, :only => [ :set ]
  map.resources :periodic_jobs, :member => { :rerun => :post }
  map.resources :store, :only => :show
  map.resources :skus, :has_many => :discounts, :shallow => true
  map.resource :user_session, :only => [ :create, :destroy, :new ]
  map.resources :users,
                :member => { :show_admin => :get,
                             :clear_avatar => :post,
                             :reset_password => :post,
                             :update_privacy => :put,
                             :update_instructor => :put,
                             :update_avatar => :put,
                             :update_roles => :put },
                :collection => { :list => :get,
                                 :user_agreement => :get }
  map.resources :user_logons
  map.resources :wish_lists, :only => [ :create, :destroy ]
  map.resources :group_invitations, :only => [ :new_private, :create_private ] do |invitation|
    invitation.resources :group_members, :only => [ :new_private, :create_private ],
                         :collection => { :new_private => :get, :create_private => :post }
  end
  map.resources :registrations, :only => [ :new, :create ] do |registration|
    registration.resources :users, :only => [ :new, :create ]
  end

  map.redirect '/admin', :controller => 'users', :action => 'list'
  map.current_cart 'cart', :controller => 'carts', :action => 'show', :id => 'current'
  map.root :controller => "lessons", :action => "index"

  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end