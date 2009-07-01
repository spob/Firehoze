# Email notifications
class Notifier < ActionMailer::Base
  default_url_options.update :protocol => APP_CONFIG[CONFIG_PROTOCOL]
  default_url_options.update :host => APP_CONFIG[CONFIG_HOST]
  default_url_options.update :port => APP_CONFIG[CONFIG_PORT]

#  default_url_options[:host] = "www.braindump.com"

  # Sent when a user requests a new password
  def password_reset_instructions(user)
    subject     "Your password has been reset"
    from         APP_CONFIG[CONFIG_ADMIN_EMAIL]
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
    from       APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :registration => registration,
               :url => new_registration_user_url(registration)
  end

  # Notify a user that they have credits about to expire
  def credits_about_to_expire(user)
    subject    "You have credits about to expire"
    recipients user.email
    from         APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :user => user,
               :url => login_url
  end

  # Notify a user that their video is ready for viewing
  def lesson_ready(lesson)
    subject    "Your lesson is ready for viewing"
    recipients lesson.instructor.email
    from         APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :lesson => lesson,
               :url => login_url
  end
end
