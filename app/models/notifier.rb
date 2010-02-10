# Email notifications
class Notifier < ActionMailer::Base
  extend HashHelper
  include ActiveSupport::CoreExtensions::String::Inflections
  
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

  def new_topic_comment(comment, user)
    subject    "A new comment has been added to #{comment.topic.group.name}"
    recipients user.email
    from       APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :comment => comment,
               :to_user => user,
               :url => topic_url(comment.topic, url_options)
  end

  # An invitation to join a private user group
  def group_invitation(invitation)
    subject    "You are invited to join a user group"
    recipients invitation.user.email
    from       APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :invitation => invitation,
               :url => new_private_group_invitation_group_members_url(invitation, url_options)
  end

  # Notify a user that they have credits about to expire
  def credits_about_to_expire(user)
    subject    "You have credits about to expire"
    recipients user.email
    from        APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :user => user,
               :url => login_url(url_options)
  end

  # ReceA job failed
  def job_failure(job)
    subject    "Periodic Job Failed ##{job.id}"
    recipients   User.admins.active.collect(&:email)
    from        APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :job => job,
               :url => periodic_jobs_url(url_options)
  end

  def flag_created(flag)
    flag = Flag.find(flag)
    subject "A #{flag.flaggable_type} was flagged"
    recipients   User.moderators.active.collect(&:email)
    from        APP_CONFIG[CONFIG_ADMIN_EMAIL]
    body        :flag => flag,
                :url => edit_flag_url(flag, url_options)
  end

  def remember_review(credit)
    subject     "#{credit.user.full_name}, please consider reviewing your purchase"
    recipients   credit.user.email
    from        APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :credit => credit,
               :url => new_lesson_review_url(credit.lesson, url_options)
  end

  # Payments...
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
               :order_date => I18n.l(order.cart.purchased_at.in_time_zone(order.user.time_zone),  :format => :w_timezone),
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
               :gift_certificates_url => account_history_my_firehoze_url(url_options),
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

  # Notify a user that their video is ready for viewing
  def new_followed_lesson(to_user, lesson)
    subject    "An instructor you are following just posted a new lesson"
    recipients to_user.email
    from       APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :lesson => lesson,
               :to_user => to_user,
               :url => lesson_url(lesson, url_options)
  end

  def contact_user(to_user, from_user, subject, msg)
    subject    "A message from a Firehoze user: #{subject}"
    recipients to_user.email
    from       from_user.email

    body       :msg => msg,
               :url_of_sender =>  user_url(from_user, url_options),
               :edit_account_url => edit_account_url(to_user, url_options),
               :to_user => to_user,
               :from_user => from_user,
               :url => login_url(url_options)
  end

  # Notify a user and admins that a video failed to transcode
  def lesson_processing_failed(video)
    subject    "The video for your lesson failed to process"
    recipients video.lesson.instructor.email
    bcc         Role.admins.active.collect(&:email)
    from         APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :video => video,
               :url => lesson_url(video.lesson, url_options)
  end

  # Notify a user and admins that a video failed to transcode
  def instructor_sign_up(user)
    user = User.find(user)
    subject    "#{user.login} became an instructor"
    recipients  User.communitymgrs.collect(&:email)
    from         APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :user => user,
               :url => user_url(user, url_options)
  end

  # Notify the admin that a video never completed their transcoding
  def lesson_processing_hung(lesson)
    subject    "The video for lesson #{lesson.id} never completed processing"
    recipients   Role.admins.active.collect(&:email)
    from         APP_CONFIG[CONFIG_ADMIN_EMAIL]

    body       :lesson => lesson,
               :url => lesson_url(lesson, url_options)
  end

  def instructor_reg_code user
    recipients "all@firehoze.com"
    from        APP_CONFIG[CONFIG_ADMIN_EMAIL]
    subject "A user has requested a reg code to become an instructor (#{user.email})"
    sent_on Time.now
    body :login => user.login, :first_name => user.first_name, :last_name => user.last_name, :email => user.email,
         :bio => user.bio, :hash => Notifier.formatted_hash(user.email, HASH_PREFIX, HASH_SUFFIX)
  end

  private

  # For some reason the default_url_options dont' seem to work when run through the task scheduler...so pass
  # them explicitly instead
  def url_options
    { :host => APP_CONFIG[CONFIG_HOST], :port => APP_CONFIG[CONFIG_PORT], :protocol => APP_CONFIG[CONFIG_PROTOCOL] }
  end
end