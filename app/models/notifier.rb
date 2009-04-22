class Notifier < ActionMailer::Base
  default_url_options.update :protocol => APP_CONFIG['protocol']
  default_url_options.update :host => APP_CONFIG['host']
  default_url_options.update :port => APP_CONFIG['port']

#  default_url_options[:host] = "www.braindump.com"

  def password_reset_instructions(user)
    subject     "Your password has been reset"
    from         APP_CONFIG['admin_email']
    recipients  user.email
    sent_on     Time.zone.now
    body        :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end
end
