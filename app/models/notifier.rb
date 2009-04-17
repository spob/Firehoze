class Notifier < ActionMailer::Base
  default_url_options[:host] = "www.braindump.com"

  def password_reset_instructions(user)
    subject     "Your password has been reset"
    from        "admin@braindump.com"
    recipients  user.email
    sent_on     Time.zone.now
    body        :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end
end
