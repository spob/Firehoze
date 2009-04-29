class UserSession < Authlogic::Session::Base
  after_create    :persist_user_logon

  # Use this member variable to prevent infinite recursion, which for some
  # reason only occurs while testing
  @user_session_persisted = false

  # Turn on the option to log the user out after inactivity
  logout_on_timeout true

  # disable the account after 10 failed login attempts
  consecutive_failed_logins_limit 10
  # and disable it for 1 hour
  failed_login_ban_for 1.hour

  private

  def persist_user_logon
    UserLogon.transaction do
      @user_session_persisted = true
      UserLogon.create(:user => attempted_record) unless @user_session_persisted
    end
  end
end