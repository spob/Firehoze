class UserSession < Authlogic::Session::Base
  # Turn on the option to log the user out after inactivity
  logout_on_timeout true
end