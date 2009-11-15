class MyFirehozeController < ApplicationController
  include SslRequirement

  before_filter :require_user
  #  verify :method => :put, :only => [ :update ], :redirect_to => :home_path
  before_filter :set_per_page, :only => [ :show ]
  before_filter :set_collection, :only => [ :show ]

  layout :layout_for_action

  def show
    mode = params[:id]

    @user = @current_user
    if params[:reset] == "y"
      # clear category browsing
      session[:browse_category_id] = nil
    end

    case mode
      when 'my_stuff'
        fetch_my_stuff_lessons
        fetch_reviews
        fetch_groups
        fetch_followed_instructors
      when 'instructor_stuff'
        fetch_instructed_lessons
        fetch_students
        fetch_followers
        fetch_payments
      when 'account_history'
      else
        # latest news
        fetch_activities
        fetch_tweets
    end
    \

    respond_to do |format|
      format.html
      format.js
    end
  end


  private

  #==================================== LATEST NEWS FETCHERS ========================================
  def fetch_activities
    @activities = case set_session_param(:browse_activities_by, "ALL")
      when 'BY_ME'
        Activity.visible_to_user(current_user).actor_user_id_equals(current_user).descend_by_acted_upon_at.paginate :per_page => ACTIVITES_PER_PAGE, :page => params[:page]
      when 'ON_ME'
        Activity.visible_to_user(current_user).actor_user_id_not_equal_to(current_user).actee_user_id_equals(current_user).descend_by_acted_upon_at.paginate :per_page => ACTIVITES_PER_PAGE, :page => params[:page]
      when 'BY_FOLLOWED'
        Activity.by_followed_instructors(current_user).descend_by_acted_upon_at.paginate :per_page => ACTIVITES_PER_PAGE, :page => params[:page]
      else
        Activity.visible_to_user(current_user).descend_by_acted_upon_at.paginate :per_page => ACTIVITES_PER_PAGE, :page => params[:page]
    end
  end

  def fetch_tweets
    @tweets = Tweet.list_tweets(FIREHOZE_TWEETS, 3)
  end

  #================================== END LATEST NEWS FETCHERS ======================================

  #==================================== MY STUFF FETCHERS ===========================================
  def fetch_my_stuff_lessons
    @lessons =
            case set_session_param("browse_activities_by", "owned")
              when 'recently_browsed'
                Lesson.fetch_latest_browsed(current_user, @category_id, @per_page, params[:page])
              when 'owned'
                Lesson.fetch_owned(current_user, @per_page, params[:page])
              when 'wishlist'
                Lesson.fetch_wishlist(current_user, @category_id, @per_page, params[:page])
            end
  end

  def fetch_reviews
    @reviews = Review.list(nil, @per_page, current_user, params[:page])
  end

  def fetch_groups
    @groups = Group.fetch_user_groups(current_user, @per_page, params[:page])
  end

  def fetch_followed_instructors
    @followed_instructors = current_user.followed_instructors.active.paginate(:per_page => @per_page, :page => params[:page])
  end

  #================================== END MY STUFF FETCHERS =========================================


  #=================================== INSTRUCTOR FETCHERS ===========================================
  def fetch_instructed_lessons
    @instructed_lessons = Lesson.fetch_instructed_lessons(current_user, @category_id, @per_page, params[:page])
  end

  def fetch_students
    @students = current_user.students.paginate(:per_page => @per_page, :page => params[:page])
  end

  def fetch_followers
    @followers = current_user.students
  end

  def fetch_payments
    @payments = current_user.payments.paginate(:per_page => @per_page, :page => params[:page])
  end

  #================================== END INSTRUCTOR FETCHERS ========================================

  def fetch_credits
    # return credit information
    @available_credits = current_user.available_credits(:order => "created_at ASC")
    @used_credits = current_user.credits.redeemed_at_not_null.expired_at_null(:order => "created_at ASC")
    @expired_credits = current_user.credits.expired_at_not_null(:order => "created_at ASC")
  end

  def set_per_page
    @per_page = %w(show).include?(params[:action]) ? 5 : Lesson.per_page
  end

  def layout_for_action
    if %w(show).include?(params[:action])
      'application_v2'
    else
      'application'
    end
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
            elsif %w(show).include?(params[:action])
              5
            else
              Lesson.per_page
            end
  end

  def set_session_param(parameter, default_value)
    session[parameter] = (params[parameter].nil? ? default_value : params[parameter])
  end
end