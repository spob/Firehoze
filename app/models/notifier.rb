# Email notifications
class Notifier < ActionMailer::Base
  default_url_options.update :protocol => APP_CONFIG['protocol']
  default_url_options.update :host => APP_CONFIG['host']
  default_url_options.update :port => APP_CONFIG['port']

#  default_url_options[:host] = "www.braindump.com"

  # Sent when a user requests a new password
  def password_reset_instructions(user)
    subject     "Your password has been reset"
    from         APP_CONFIG['admin_email']
    recipients  user.email
    sent_on     Time.zone.now
    body        :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  # Sent when a user has requested an account. This email allows the user to confirm their email address.
  # This email notification employs the active_url gem to encrypt the url:
  # See http://github.com/mholling/active_url/tree/master for more information
  def registration(registration)
    #asf
    subject    "Registration successful"
    recipients registration.email
    from       "admin@website.com"

    body       :registration => registration,
               :url => new_registration_user_url(registration)
  end
end
