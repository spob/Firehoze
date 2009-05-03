class UserSession < Authlogic::Session::Base
  after_persisting    :persist_user_logon

  # Turn on the option to log the user out after inactivity
  logout_on_timeout true

  # disable the account after 10 failed login attempts
  consecutive_failed_logins_limit 10
  # and disable it for 1 hour
  failed_login_ban_for 1.hour

  private

  def persist_user_logon
    # for some reason when running in test mode, this causes infinite recursion...
    # so, at least for now, disable this in test mode
    unless ENV['RAILS_ENV'] == 'test'
#      if record
#        UserLogon.create(:user => record,
#                :login_ip => record.current_login_ip)
#      end
    end
  end
end