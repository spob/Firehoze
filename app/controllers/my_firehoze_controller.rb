class MyFirehozeController < ApplicationController
  include SslRequirement

  before_filter :require_user
  #  verify :method => :put, :only => [ :update ], :redirect_to => :home_path
  before_filter :set_per_page, :only => [ :show ]
  layout :layout_for_action

  def show
    @user = @current_user
    if params[:reset] == "y"
      # clear category browsing
      session[:browse_category_id] = nil
    end
    fetch_activities
    fetch_credits
    fetch_tweets

    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def fetch_activities    
    if params[:browse_activities_by] == 'BY_ME' and current_user
      session[:browse_activities_by] = 'BY_ME'
    elsif params[:browse_activities_by] == 'ON_ME' and current_user
      session[:browse_activities_by] = 'ON_ME'
    elsif params[:browse_activities_by] == 'BY_FOLLOWED' and current_user
      session[:browse_activities_by] = 'BY_FOLLOWED'
    else
      session[:browse_activities_by] = 'ALL'
    end
    
    if session[:browse_activities_by] == 'BY_ME'
      @activities = Activity.visible_to_user(current_user).actor_user_id_equals(current_user).descend_by_acted_upon_at.paginate :per_page => ACTIVITES_PER_PAGE, :page => params[:page]
    elsif session[:browse_activities_by] == 'ON_ME'
      @activities = Activity.visible_to_user(current_user).actor_user_id_not_equal_to(current_user).actee_user_id_equals(current_user).descend_by_acted_upon_at.paginate :per_page => ACTIVITES_PER_PAGE, :page => params[:page]
    elsif session[:browse_activities_by] == 'BY_FOLLOWED'
      @activities = Activity.by_followed_instructors(current_user).descend_by_acted_upon_at.paginate :per_page => ACTIVITES_PER_PAGE, :page => params[:page]
    else
      @activities = Activity.visible_to_user(current_user).descend_by_acted_upon_at.paginate :per_page => ACTIVITES_PER_PAGE, :page => params[:page]
    end
  end

  def fetch_credits
    # return credit information
    @available_credits = current_user.available_credits(:order => "created_at ASC")
    @used_credits = current_user.credits.redeemed_at_not_null.expired_at_null(:order => "created_at ASC")
    @expired_credits = current_user.credits.expired_at_not_null(:order => "created_at ASC")
  end

  def fetch_tweets
    @tweets = Tweet.list_tweets(FIREHOZE_TWEETS, 3)
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
end
