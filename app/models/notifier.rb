# Email notifications
class Notifier < ActionMailer::Base
  #default_url_options.update :protocol => APP_CONFIG[CONFIG_PROTOCOL]
  #default_url_options.update :host => APP_CONFIG[CONFIG_HOST]
  #default_url_options.update :port => APP_CONFIG[CONFIG_PORT]

  default_url_options[:protocol] = APP_CONFIG[CONFIG_PROTOCOL]
  default_url_options[:host] = APP_CONFIG[CONFIG_HOST]
  default_url_options[:port] = APP_CONFIG[CONFIG_PORT]

  # Sent when a user requests a new password
  def password_reset_instructions(user)
    subject     "Your password has been reset"
    from         APP_CONFIG[CONFIG_ADMIN_EMAIL]
    recipients  user.email
    sent_on     Time.zone.now
    body        :edit_password_reset_url => edit_password_reset_url(user.perishable_token, url_options)
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
               :url => new_registration_user_url(registration, url_options)
  end

  # Notify a user that they have credits about to expire
  def credits_about_to_expire(user)
    subject    "You have credits about to expire"
    recipients user.email
    from        APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :user => user,
               :url => login_url(url_options)
  end

  # Receipt for an order
  def job_failure(job)
    subject    "Periodic Job Failed ##{job.id}"
    recipients   User.admins.active.collect(&:email)
    from        APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :job => job,
               :url => periodic_jobs_url(url_options)
  end

  def remember_review(credit)
    subject     "#{credit.user.full_name}, please consider reviewing your purchase"
    recipients   credit.user.email
    from        APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :credit => credit,
               :url => new_lesson_review_path(credit.lesson, url_options)
  end

  # Receipt for an order
  def payment_notification(payment_id)
    payment = Payment.find(payment_id)
    subject    "The check is in the mail!"
    recipients  payment.user.email
    from        APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :payment => payment,
               :url => payment_url(payment, url_options)
  end

  # Receipt for an order
  def receipt_for_order(order)
    subject    "Receipt for order ##{order.id}"
    recipients order.user.email
    from        APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :order => order,
               :url => order_url(order, url_options)
  end

  # You received a gift certificate
  def gift_certificate_received(gift_certificate, from_user)
    subject      "You have received a gift"
    recipients    gift_certificate.user.email
    from          APP_CONFIG[CONFIG_ADMIN_EMAIL]
    #content_type "multipart/alternative"

    body       :gift_certificate => gift_certificate,
               :from_user => from_user,
               :gift_certificates_url => gift_certificates_url(url_options),
               :redeem_url => new_gift_certificate_url(url_options),
               :url => login_url(url_options)
  end

  # Notify a user that their video is ready for viewing
  def lesson_ready(lesson)
    subject    "Your lesson is ready for viewing"
    recipients lesson.instructor.email
    from         APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :lesson => lesson,
               :url => lesson_url(lesson, url_options)
  end

  def contact_user(to_user, from_user, subject, msg)
    subject    "A message from a Firehoze user: #{subject}"
    recipients to_user.email
    from       from_user.email

    body       :msg => msg,
               :to_user => to_user,
               :from_user => from_user,
               :url => login_url(url_options)
  end

  # Notify a user and admins that a video failed to transcode
  def lesson_processing_failed(video)
    subject    "The video for your lesson failed to process"
    recipients video.lesson.instructor.email
    bcc         Role.admins.collect(&:email)
    from         APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :video => video,
               :url => lesson_url(video.lesson, url_options)
  end

  # Notify the admin that a video never completed their transcoding
  def lesson_processing_hung(lesson)
    subject    "The video for lesson #{lesson.id} never completed processing"
    recipients Role.admins.collect(&:email)
    from         APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :lesson => lesson,
               :url => lesson_url(lesson, url_options)
  end

  private

  # For some reason the default_url_options dont' seem to work when run through the task scheduler...so pass
  # them explicitly instead
  def url_options
    { :host => APP_CONFIG[CONFIG_HOST], :port => APP_CONFIG[CONFIG_PORT], :protocol => APP_CONFIG[CONFIG_PROTOCOL] }
  end
end