class UserSession < Authlogic::Session::Base
  # Turn on the option to log the user out after inactivity
  logout_on_timeout true

  # disable the account after 10 failed login attempts
  consecutive_failed_logins_limit 10
  # and disable it for 1 hour
  failed_login_ban_for 1.hour
end