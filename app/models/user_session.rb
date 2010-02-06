# This class is used by the AuthLogic gem to control aspects of the authentication behavior
class UserSession < Authlogic::Session::Base
  # Turn on the option to log the user out after inactivity
  logout_on_timeout true

  # How long to wait before logging out an inactive user
  logged_in_timeout = 15.minutes

  # disable the account after 10 failed login attempts to protect against brute force attacks
  consecutive_failed_logins_limit 10
  # and disable it for 1 hour
  failed_login_ban_for 1.hour
end