class MyFirehozeController < ApplicationController
  include SslRequirement

  before_filter :require_user
  #  verify :method => :put, :only => [ :update ], :redirect_to => :home_path
  before_filter :set_per_page, :only => [ :show, :my_stuff, :instructor ]
  before_filter :set_collection, :only => [ :show ]
  before_filter :setup

  def goto_remembered_tab
    if cookies[:my_firehoze_tab] and params[:clear].nil? and cookies[:my_firehoze_tab] != params[:action]
      redirect_to :controller => 'my_firehoze', :action => cookies[:my_firehoze_tab]
      return true
    end
    false
  end

  def index
    fetch_activities
    fetch_tweets

    respond_to do |format|
      format.html do
        unless goto_remembered_tab
          cookies[:my_firehoze_tab] = { :value => params[:action], :expires => 1.hour.from_now }
        end
      end
      format.js
    end
  end

  def my_stuff
    fetch_my_stuff_lessons
    fetch_reviews
    fetch_groups
    fetch_followed_instructors
    respond_to do |format|
      format.html do
        cookies[:my_firehoze_tab] = { :value => params[:action], :expires => 1.hour.from_now }
      end
      format.js do
        case params[:pane]
          when 'owned', 'latest_browsed', 'wishlist'
            render :action => "lessons"
          else
            render :action => params[:pane]
        end
      end
    end
  end

  def instructor
    fetch_instructed_lessons
    fetch_students
    fetch_payments

    respond_to do |format|
      format.html do
        cookies[:my_firehoze_tab] = { :value => params[:action], :expires => 1.hour.from_now }
      end
      format.js do
        case params[:pane]
          when 'lessons_instructed_tn_view'
            render :action => "lessons"
          when 'lessons_instructed_table_view'
            render :action => "lessons_instructed_table_view"
          else
            render :action => params[:pane]
        end
      end
    end
  end

  def account_history
    fetch_orders
    fetch_credits
    fetch_gift_certificates

    respond_to do |format|
      format.html do
        cookies[:my_firehoze_tab] = { :value => params[:action], :expires => 1.hour.from_now }
      end
      format.js
    end
  end


  private

  def setup
    @user = @current_user
    session[:browse_category_id] = nil if params[:reset] == "y"
  end

  def fetch_activities
    activites_per_page = 8
    @activities = case set_cookie_param(:browse_activities_by, "ALL")
      when 'BY_ME'
        Activity.visible_to_user(current_user).actor_user_id_equals(current_user).descend_by_acted_upon_at.paginate :per_page => activites_per_page, :page => params[:page]
      when 'ON_ME'
        Activity.visible_to_user(current_user).actor_user_id_not_equal_to(current_user).actee_user_id_equals(current_user).descend_by_acted_upon_at.paginate :per_page => activites_per_page, :page => params[:page]
      when 'BY_FOLLOWED'
        Activity.by_followed_instructors(current_user).descend_by_acted_upon_at.paginate :per_page => activites_per_page, :page => params[:page]
      else
        Activity.visible_to_user(current_user).descend_by_acted_upon_at.paginate :per_page => activites_per_page, :page => params[:page]
    end
  end

  def fetch_tweets
    @tweets = Tweet.list_tweets(FIREHOZE_TWEETS, 10)
  end

  def fetch_my_stuff_lessons
    @latest_browsed = Lesson.fetch_latest_browsed(current_user, @category_id, @per_page, params[:page]) if retrieve_by_pane("latest_browsed")
    @owned = Lesson.fetch_owned(current_user, @per_page, params[:page]) if retrieve_by_pane("owned")
    @wishlist = Lesson.fetch_wishlist(current_user, @category_id, @per_page, params[:page]) if retrieve_by_pane("wishlist")
  end

  def fetch_reviews
    @reviews = current_user.reviews.ready(:include => [:user, :lesson]).paginate(:page => params[:page], :per_page => @per_page) if retrieve_by_pane("reviews")
  end

  def fetch_groups
    @groups = Group.fetch_user_groups(current_user, params[:page], @per_page) if retrieve_by_pane("groups")
  end

  def fetch_followed_instructors
    @followed_instructors = current_user.followed_instructors.active.paginate(:per_page => @per_page, :page => params[:page]) if retrieve_by_pane("followed_instructors")
  end

  def fetch_instructed_lessons
    if retrieve_by_pane("lessons_instructed_table_view") or retrieve_by_pane("lessons_instructed_tn_view")
      @instructed_lessons = Lesson.fetch_instructed_lessons(current_user, @category_id, @per_page, params[:page])
    end
  end

  def fetch_students
    @followers = current_user.followers
    @students = current_user.students.paginate(:per_page => @per_page, :page => params[:page])
  end

  def fetch_payments
    @payments = current_user.payments.paginate(:per_page => @per_page, :page => params[:page])
  end

  def fetch_credits
    @used_credits = current_user.credits.redeemed_at_not_null.expired_at_null(:include => [:sku, :line_item, :lesson], :order => "created_at ASC")
    @expired_credits = current_user.credits.expired_at_not_null(:include => [:sku, :line_item, :lesson], :order => "created_at ASC")
    @available_credits = current_user.available_credits(:include => [:sku, :line_item, :lesson], :order => "created_at ASC")
  end

  def fetch_orders
    @orders = current_user.orders.cart_purchased_at_not_null.descend_by_id(:include => [:cart])
  end

  def fetch_gift_certificates
    @gift_certificates = current_user.gift_certificates.ascend_by_id.active
  end

  def set_collection
    @collection = params[:collection]
    raise "Invalid collection" unless (LIST_COLLECTIONS).include?(@collection)
  rescue
    false
  end

  def set_per_page
    @per_page =
            if params[:per_page]
              params[:per_page]
            elsif %w(my_stuff instructor show).include?(params[:action])
              10
            else
              Lesson.per_page
            end
  end

  def set_cookie_param(parameter, default_value)
    if params[parameter].present?
      set_cookie(parameter, params[parameter])
    elsif cookies[parameter].nil?
      set_cookie(parameter, default_value)
    end
  end

  def set_cookie param, value
    cookies[param] = { :value => value, :expires => 1.hour.from_now }
    cookies[param]
  end

  def retrieve_by_pane(pane)
    params[:pane].nil? or params[:pane] == pane
  end
end
