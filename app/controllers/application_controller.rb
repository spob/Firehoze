# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation
  filter_parameter_logging :card_number, :card_verification
  before_filter :set_timezone
  before_filter :set_user_language

  def available_locales; AVAILABLE_LOCALES; end

  # The currently logged on user, or nil if no user is logged on
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
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

  # Set the timezone for a given user based upon their preference...if not logged on, use the system
  # default time time...this is called by the before_filter
  def set_timezone
    # current_user.time_zone #=> 'London'
    Time.zone = current_user ? current_user.time_zone : APP_CONFIG['default_user_timezone']
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  # helper method to require that a user is logged on...used within controllers
  def require_user
    unless current_user
      store_location
      #flash[:notice] = t 'test.abc'
      flash[:notice] = t 'security.you_must_be_logged_in'
      redirect_to new_user_session_url
      return false
    end
  end

  # helper method to require that a user is NOT logged on...used within controllers
  def require_no_user
    if current_user
      store_location
      flash[:notice] = t 'security.you_must_be_logged_out'
      redirect_to account_url
      return false
    end
  end

  # store the location that the user navigated to...used so that, if we need to redirect to
  # the login page, we can continue on to this location after the user authenticates
  def store_location
    session[:return_to] = request.request_uri
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
