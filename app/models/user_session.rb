# This class is used by the AuthLogic gem to control aspects of the authentication behavior
class UserSession < Authlogic::Session::Base
  # Turn on the option to log the user out after inactivity
  logout_on_timeout true

  # disable the account after 10 failed login attempts to protect against brute force attacks
  consecutive_failed_logins_limit 10
  # and disable it for 1 hour
  failed_login_ban_for 1.hour

  after_create :create_audit
  after_persisting :create_audit

  before_destroy :delete_logged_cookie

  private

  def first_persist? user
    # I don't think the cookies work in test mode, so stub it out
    return false if Rails.env.test?
    first = controller.cookies[:logged_user_session] != user.login and
    controller.cookies[:logged_user_session] = { :value => user.login, :expires => 1.hour.from_now }
    first
  end

  def delete_logged_cookie
    controller.cookies.delete :logged_user_session
  end

  def create_audit
    user = attempted_record

    if first_persist? user
      UserLogon.create(:user => user, :login_ip => user.current_login_ip)

      # Also touch the available credit records for this user...used for calculating which credits should
      # expire due to lack of activity on the account
      user.credits.available.update_all(:will_expire_at => APP_CONFIG[CONFIG_EXPIRE_CREDITS_AFTER_DAYS].days.since,
                                        :expiration_warning_issued_at => nil )
    end
  end
end