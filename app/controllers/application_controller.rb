# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SslRequirement
  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    flash[:error] = t('security.invalid_token')
    redirect_to login_path
  end

  rescue_from ActiveRecord::StaleObjectError do |exception|
    flash[:error] = t('general.optimistic_lock_error')
    redirect_to my_firehoze_index_path
  end

  helper_attr :facebook_session
  attr_accessor :facebook_session
  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation, :current_password, :card_number, :card_verification
  before_filter :set_timezone
  before_filter :set_user_language
  before_filter :check_browser
  before_filter :require_login_for_facebook

  protect_from_forgery :only => [:update, :delete, :create]

  def available_locales;
    AVAILABLE_LOCALES;
  end

  # The currently logged on user, or nil if no user is logged on
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.attempted_record
  end

  def require_login_for_facebook
    if params[:format] == 'fbml'
      ensure_authenticated_to_facebook
      ensure_application_is_installed_by_facebook_user
      set_facebook_session

      if !session[:facebook_session].nil?
        @facebook_session = session[:facebook_session]
        # we'll do something with users
        # here in the next post about fb
      end
    end
  end

  # Retrieve the current shopping cart, instantiating a new one if one does not already exist
  def current_cart
    if current_user
      if session[:cart_id]
        begin
          # retrieve the current shopping cart based upon the id stored in the session
          @current_cart ||= Cart.find(session[:cart_id])
          session[:cart_id] = nil if @current_cart.purchased_at or @current_cart.user != current_user
        rescue ActiveRecord::RecordNotFound
          # This can happen if the surrounding transaction (i.e, creating a line item in the cart)
          # fails and rolls back
          session[:cart_id] = nil
        end
      end
      # A cart doesn't already exist...create one
      if session[:cart_id].nil?
        @current_cart = Cart.create!(:user => current_user)
        session[:cart_id] = @current_cart.id
      end
      @current_cart
    end
  end


# Allow you to use text helper (pluralize) from within controllers.
# See http://snippets.dzone.com/posts/show/1799
  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::NumberHelper
  end


  private

  def check_browser
    return true if Rails.env.test?
    @detector = SpobBrowserDetector::Detector.new( request.env['HTTP_USER_AGENT'] )
    by_pass = (!@detector.browser_is?(:name => 'ie', :major_version => '6') or (params[:controller] == 'pages' or (params[:controller] == 'lessons' and params[:action] == 'index')))
    if (cookies[:browser_ok] == "ok" or by_pass)
      true
    else
      cookies[:browser_ok] = { :value => "ok", :expires => 1.day.from_now }
      redirect_to page_path("browser_check")
      false
    end
  end

  # Set the timezone for a given user based upon their preference...if not logged on, use the system
  # default time time...this is called by the before_filter
  def set_timezone
    Time.zone = current_user.try(:time_zone) || APP_CONFIG[CONFIG_DEFAULT_USER_TIMEZONE]
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find

#    if @current_user_session.try('stale?')
#      redirect_to new_user_session_url(:stale => true)
#      return false
#    end
    @current_user_session
  end

  # helper method to require that a user is logged on...used within controllers
  def require_user url=nil
    unless current_user
      if (url)
        store_location url
      else
        store_location
      end
      flash[:error] = t 'security.you_must_be_logged_in'
      redirect_to new_user_session_url
      return false
    end
    true
  end

  # helper method to require that a user is NOT logged on...used within controllers
  def require_no_user
    if current_user
      store_location
      flash[:error] = t 'security.you_must_be_logged_out'
      redirect_to my_firehoze_index_path
      return false
    end
  end

  # store the location that the user navigated to...used so that, if we need to redirect to
  # the login page, we can continue on to this location after the user authenticates
  def store_location uri=request.request_uri
    session[:return_to] =
            if request.get?
              uri
            else
              request.referer
            end
  end

  # redirect back to where the user was trying to get to if, for example, we needed to first redirect
  # him/her to authenticate
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # Set the local based on the user's language (or english if the user isn't logged in)
  # Called by the before filter
  def set_user_language
    I18n.locale = current_user.try(:language) || 'en'
  end
end
