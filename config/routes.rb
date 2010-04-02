ActionController::Routing::Routes.draw do |map|

  map.home 'home', :controller => 'home', :action => 'show'
  map.resources :my_firehoze, :only => [ :index ],
                :collection => { :instructor => :get,
                                 :my_stuff => :get,
                                 :account_history => :get }
  map.resources :accounts, :except => [ :show ],
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
                             :update_privacy => :put,
                             :edit_instructor => :get,
                             :edit_avatar => :get,
                             :edit_facebook => :get,
                             :update_facebook => :put,
                             :clear_facebook => :post,
                             :edit_privacy => :get,
                             :request_instructor_reg_code => :post },
                :collection => { :instructor_agreement => :get }
  map.resources :acquire_lessons, :only => [ :create, :new ],
                :collection => { :ajaxed => :get }
  map.resources :admin_consoles, :only => [ :index ]
  map.resources :carts, :only => [ :show ]
  map.resources :categories, :collection => { :explode => :post, :list_admin => :get }
  map.resources :contact_users, :only => [ :create, :new ]
  map.resources :facebooks, :only => [ :index, :connect ], :member => { :connect => :get }
#  map.resources :credits
  map.resources :flags, :only => [ :new, :create, :index, :show, :update, :edit ]
  map.check_gift_code "gift_certificates/check_gift_certificate_code", :controller => "gift_certificates", :action => "check_gift_certificate_code"
  map.resources :gift_certificates,
                :collection => { :list_admin => :get },
                :member => { :redeem => :post,
                             :give => :post,
                             :pregive => :get,
                             :confirm_give => :post }
  map.resources :grant_gift_certificates, :only => [ :create, :new ]
  map.check_group_by_name "groups/check_group_by_name", :controller => "groups", :action => "check_group_by_name"
  map.resources :groups,
                :collection => { :list_admin => :get,
                                 :ajaxed => :get,
                                 :all_tags => :get,
                                 :tagged_with => :get },
                :member => { :clear_logo => :post, :activate => :post },
                :has_many => :topics, :shallow => true
  map.check_group_invite_user "group_invitations/check_user", :controller => "group_invitations", :action => "check_user"
  map.resources :group_invitations, :only => [ :create, :new ]
  map.resources :group_lessons, :only => [ :create, :destroy ]
  map.resources :group_members, :only => [ :create, :destroy ],
                :member => { :remove => :delete, :promote => :post, :demote => :post, :create_private => :post }
  map.resources :group_invitations, :only => [ :new_private, :create_private ] do |invitation|
    invitation.resources :group_members, :only => [ :new_private, :create_private ],
                         :collection => { :new_private => :get }
  end
  map.resources :helpfuls, :only => [ :create ]
  map.resources :instructor_follows, :only => [ :create, :destroy ],
                :collection => { :ajaxed => :get }
  map.resources :reviews, :collection => { :ajaxed => :get }
  map.check_lesson_by_title "lessons/check_lesson_by_title", :controller => "lessons", :action => "check_lesson_by_title"
  map.resources :lessons, :has_many => :reviews, :shallow => true,
                :member => {
                        :convert => :post,
                        :lesson_notes => :get,
                        :rate => :post,
#                        :recommend => :get,
                        :stats => :get,
                        :show_groups => :get,
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
                        :all_tags => :get,
                        :advanced_search => :get,
                        :perform_advanced_search => :get,
                        :graph => :get,
                        :graph_code => :get
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
  map.resources :pages, :controller => 'pages', :only => [:show]
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :passwords, :only => [ :edit, :update ]
  map.resources :password_resets, :only => [ :create, :new, :edit, :update, :show ]
  map.resources :payment_levels
  map.resources :payments, :member => { :show_unpaid => :get,
                                        :list => :get },
                :collection => { :ajaxed => :get },
                :only => [:index, :show, :show_unpaid, :create]
  map.resources :per_pages, :collection => { :set => :post }, :only => [ :set ]
  map.resources :periodic_jobs, :member => { :rerun => :post, :run_now => :post }
  map.resources :promotions, :except => [ :show ]
  map.resources :searches, :only => [ :index ]
  map.resources :store, :only => :show
  map.resources :skus, :has_many => :discounts, :shallow => true
  map.resource :user_session, :only => [ :create, :destroy, :new ]
  map.resources :topics, :has_many => :topic_comments, :shallow => true
  map.check_user "registrations/check_user", :controller => "registrations", :action => "check_user"
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
  map.resources :user_logons, :collection => { :graph => :get, :graph_code => :get },
                :only => [ :index, :graph, :graph_code ]
  map.resources :wish_lists, :only => [ :create, :destroy ]
  map.resources :registrations, :only => [ :new, :create, :show ] do |registration|
    registration.resources :users, :only => [ :new, :create ]
  end

  map.redirect '/admin', :controller => 'users', :action => 'list'
  map.current_cart 'cart', :controller => 'carts', :action => 'show', :id => 'current'
  map.root :controller => "lessons", :action => "index"

  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end