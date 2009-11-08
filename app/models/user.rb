# As its name implies, a user is a authorized user of the site. It contains information about the user
# (for example, first and last name), their encrypted password, etc.
class User < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  
  has_friendly_id :login

  # Ajaxful-rating plugin
  ajaxful_rater

  # Authorization plugin
  acts_as_authorized_user

  before_save :persist_user_logon
  before_validation :strip_fields

  acts_as_authentic  do |c|
    c.logged_in_timeout = 30.minutes # log out after 30 minutes of inactivity
  end

  has_many :user_logons, :order => "created_at DESC", :dependent => :destroy
  has_many :credits, :order => 'id', :dependent => :destroy
  has_many :group_members, :dependent => :destroy
  has_many :groups, :through => :group_members
  has_many :group_ids, :select => 'group_id', :class_name => 'GroupMember'
  has_many :moderated_groups, :source => :group, :through => :group_members,
           :conditions => { :group_members => { :member_type => [ OWNER, MODERATOR ] } }
  has_many :member_groups, :source => :group, :through => :group_members,
           :conditions => { :group_members => { :member_type => [ OWNER, MODERATOR, MEMBER ] } }
  has_many :gift_certificates, :dependent => :destroy
  has_many :orders, :order => 'id DESC', :dependent => :destroy
  has_many :visited_lessons, :source => :lesson, :through => :lesson_visits, :order => 'visited_at DESC'
  has_many :latest_visited_lessons, :source => :lesson, :through => :lesson_visits,
           :conditions => 'latest = 1', :order => 'visited_at DESC'
  has_many :lesson_visits, :order => 'visited_at DESC', :dependent => :destroy
  # the times this user's profile has been flagged
  has_many :flags, :as => :flaggable, :dependent => :destroy
  # the times this user has reported in appropriate content
  has_many :flaggings, :class_name => 'Flag'
  has_many :lesson_comments
  has_many :available_credits, :class_name => 'Credit',
           :conditions => { :redeemed_at => nil },
           :order => "id"
  # Instructed represents lessons that this user has instructed
  has_many :instructed_lessons, :class_name => 'Lesson', :foreign_key => 'instructor_id', :order => 'rating_average desc, id'
  has_many :instructed_lesson_ids, :class_name => 'Lesson', :select => 'id', :foreign_key => 'instructor_id', :order => 'rating_average desc, id'
  # Lessons represents lessons that this user has "bought"
  has_many :lessons, :through => :credits
  has_many :lesson_ids, :select => 'lessons.id', :source => 'lesson', :through => :credits
  has_many :payments, :order => 'id DESC'
  has_many :reviews, :order => 'score desc, id', :dependent => :destroy
  has_many :helpfuls, :dependent => :destroy
  belongs_to :payment_level
  has_and_belongs_to_many :wishes, :join_table => 'wishes', :class_name => 'Lesson'
  has_and_belongs_to_many :followed_instructors, :join_table => 'instructor_follows',
                          :class_name => 'User', :foreign_key => 'instructor_id'
  has_and_belongs_to_many :followers, :join_table => 'instructor_follows',
                          :class_name => 'User', :association_foreign_key => 'instructor_id'

  # Active users
  named_scope :active, :conditions => {:active => true}

  named_scope :admins,
              :joins => [:roles],
              :conditions => { :roles => {:name => 'admin'}},
              :order => :email

  sql = %Q{
    address1 is not null and
    city is not null and
    state is not null and
    postal_code is not null and
    country is not null and
    verified_address_on is not null and
    author_agreement_accepted_on is not null and
    payment_level_id is not null
  }

  named_scope :instructors,
              :conditions => sql

  # Used to verify current password during password changes
  attr_accessor :current_password

  validates_presence_of     :login_count, :failed_login_count, :last_name, :instructor_status, :language
  validates_presence_of     :user_agreement_accepted_on #, :message => :must_accept_agreement
  validates_presence_of     :login#, :message => :login_required
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_uniqueness_of   :login, :case_sensitive => false
  validates_numericality_of :login_count, :failed_login_count
  validates_length_of       :email, :maximum => 100, :allow_nil => true
  validates_length_of       :last_name, :maximum => 40, :allow_nil => true
  validates_length_of       :first_name, :maximum => 40, :allow_nil => true
  validates_length_of       :login, :maximum => 25, :allow_nil => true

  # PAPERCLIP
  has_attached_file :avatar,
                    :styles => {
                            :tiny => ["35x35#", :png],
                            :small => ["75x75#", :png],
                            :medium => ["110x110#", :png],
                            :large => ["220x220#", :png]
                    },
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :s3_permissions => 'public-read',
                    :path => "#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/users/:attachment/:id/:style/:basename.:extension",
                    :bucket => APP_CONFIG[CONFIG_AWS_S3_IMAGES_BUCKET]

  validates_attachment_size :avatar, :less_than => 1.megabytes, :message => "All uploaded images must be less then 1 megabyte"
  validates_attachment_content_type :avatar, :content_type => [ 'image/gif', 'image/png', 'image/x-png', 'image/jpeg', 'image/pjpeg', 'image/jpg' ]

  attr_protected :email, :login, :rejected_bio, :instructor_status, :address1, :address2, :city, :state,
                 :postal_code, :country, :author_agreement_accepted_on, :withold_taxes, :payment_level_id
  attr_protected :user_logons, :credits, :gift_certificates, :orders, :lesson_visits,
                 :flags, :flaggings, :lesson_comments, :instructed_lessons, :payments, :reviews, :helpfuls, :wishes

  @@flag_reasons = [
          FLAG_LEWD,
          FLAG_SPAM,
          FLAG_OFFENSIVE ]

  def self.flag_reasons
    @@flag_reasons
  end

  def self.default_avatar_url(style)
    # "http://#{APP_CONFIG[CONFIG_AWS_S3_IMAGES_BUCKET]}/users/avatars/missing/%s/missing.png" % style.to_s
    "/images/users/avatars/%s/missing.png" % style.to_s
  end

  # convert an amazon url for an avator to a cdn url
  def self.convert_avatar_url_to_cdn(url)
    regex = Regexp.new("//.*#{APP_CONFIG[CONFIG_AWS_S3_IMAGES_BUCKET]}")
    regex2 = Regexp.new("https")
    url.gsub(regex, "//" + APP_CONFIG[CONFIG_CDN_OUTPUT_SERVER]).gsub(regex2, "http")
  end

  # This method is a decorator and it's sole purpose is to enable memoization
  def is_a_moderator?
    self.is_moderator?
  end
  memoize :is_a_moderator?

  # This method is a decorator and it's sole purpose is to enable memoization 
  def is_an_admin?
    self.is_admin?
  end
  memoize :is_an_admin?

  def self.supported_languages
    LANGUAGES
  end

  # Reset the password token and then send the user an email
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  # used to verify whether the user typed their correct password when, for example,
  # the user updates their password
  def valid_current_password?
    unless valid_password?(current_password.try(:strip))
      errors.add(:current_password, "is incorrect")
      return false
    end
    true
  end

  def address_provided?
    not_blank_or_nil(address1) and not_blank_or_nil(city) and
            not_blank_or_nil(state) and not_blank_or_nil(postal_code) and
            not_blank_or_nil(country)
  end

  # Utility method to return either the last_name if no first name is specified, or the first and last
  # name with a space betwen them
  def full_name
    return last_name if first_name.nil? or first_name.empty?
    "#{first_name} #{last_name}".strip
  end

  # Has this user purchased this lesson?
  def owns_lesson? lesson
    !self.lessons.scoped_by_id(lesson).first.nil?
  end

  def instructor? lesson
    self == lesson.instructor
  end

  def generate_payment
    payment = Payment.create(:user => self, :amount => 0)
    payment.apply_unpaid_credits
    payment
  end

  def verified_instructor?
    (address_provided? and verified_address_on and author_agreement_accepted_on and payment_level)
  end

  def city_and_state
    [ city, state ].reject { |e| e.blank? }.join(', ')
  end

  def name_or_username
    return 'Firehoze member' if username.blank? and username.blank?
    if self.show_real_name
      full_name
    else
      username
    end
  end

  def username
    login
  end

  def can_edit? current_user
    (current_user and (current_user.is_admin? or current_user.is_moderator?))
  end

  def on_wish_list? lesson
    self.wishes.find_by_id(lesson.id)
  end

  def owned_and_instructed_lessons
    lessons + instructed_lessons
  end

  def reject
    self.rejected_bio = true
  end

  def has_flagged? (flaggable)
    !get_flags(flaggable).empty?
  end

  def has_flagged_rejected? (flaggable)
    flags = get_flags(flaggable)
    if flags.empty?
      false
    else
      flags.collect(&:status).include? FLAG_STATUS_REJECTED
    end
  end

  def get_flags(flaggable)
    klass = flaggable.class
    # for some reason rails settings the flaggable type to Comment instead of LessonComment
    klass = Comment if flaggable.class.to_s == "LessonComment"
    flaggings.by_flaggable_type(klass).find_all_by_flaggable_id(flaggable.id)
  end

  # Has this user specified by the parameter bought of this this user's lessons'
  def student_of?(user)
    user.lessons.collect(&:instructor).include?(self)
  end


  # Can the user parameter contact this user via email?
  def can_contact?(user)
    allow_contact == USER_ALLOW_CONTACT_ANYONE or
            (allow_contact == USER_ALLOW_CONTACT_STUDENTS_ONLY and student_of?(user))
  end

  def unpaid_credits
    Credit.unpaid_credits(self)
  end

  def unpaid_credits_amount
    amount = 0
    Credit.unpaid_credits(self).each do |credit|
      amount = amount + round_to_penny(credit.price * self.payment_level.rate)
    end
    amount
  end

  def followed_by?(user)
    self.followers.find_by_id(user, :select => [:id])
  end

  private

  def strip_fields
    self.login = self.login.strip if self.login
  end

  def round_to_penny amount
    amount = (amount * 100.0).floor
    amount/100.0
  end

  def persist_user_logon
    if login_count > login_count_was
      # Surprisingly AuthLogic doesn't provide a clean callback for detecting when a login occurs...so instead,
      # watch for when the login count is incremented (which is done by AuthLogic).
      UserLogon.create(:user => self,
                       :login_ip => self.current_login_ip)

      # Also touch the available credit records for this user...used for calculating which credits should
      # expire due to lack of activity on the account
      self.credits.available.update_all(:will_expire_at => APP_CONFIG[CONFIG_EXPIRE_CREDITS_AFTER_DAYS].days.since,
                                        :expiration_warning_issued_at => nil )
    end
  end

  def not_blank_or_nil field
    !field.nil? and !field.blank?
  end
end