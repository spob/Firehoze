# As its name implies, a user is a authorized user of the site. It contains information about the user
# (for example, first and last name), their encrypted password, etc.
class User < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  has_friendly_id :login

  is_gravtastic!

  # Ajaxful-rating plugin
  ajaxful_rater

  # Authorization plugin
  acts_as_authorized_user

  before_validation :strip_fields
  after_update :reprocess_avatar, :if => :cropping?

  acts_as_authentic do |c|
    c.logged_in_timeout = 1.hour # log out after specified time
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
  has_many :activities, :as => :trackable, :dependent => :destroy
  has_many :available_credits, :class_name => 'Credit',
           :conditions => { :redeemed_at => nil, :expired_at => nil },
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
                          :class_name => 'User', :foreign_key => 'user_id', :association_foreign_key => 'instructor_id',
                          :order => 'login ASC'
  has_and_belongs_to_many :followers, :join_table => 'instructor_follows',
                          :class_name => 'User', :foreign_key => 'instructor_id',
                          :association_foreign_key => 'user_id', :order => 'login ASC'

  # Active users
  named_scope :active, :conditions => {:active => true}

  named_scope :admins,
              :joins => [:roles],
              :conditions => { :roles => {:name => 'admin'}},
              :order => :email
  named_scope :moderators,
              :joins => [:roles],
              :conditions => { :roles => {:name => 'moderator'}},
              :order => :email
  named_scope :communitymgrs,
              :joins => [:roles],
              :conditions => { :roles => {:name => 'communitymgr'}},
              :order => :email
    logons_sql = <<END
            id IN
            (SELECT user_id
            FROM user_logons
            WHERE created_at >= ? and created_at < ?)
END
  named_scope :unique_logons_by_date,
              lambda{ |days_ago| 
              { :conditions => [logons_sql,
                                Time.mktime(Time.now.year,Time.now.month,Time.now.day) - (days_ago * 86400),
                                Time.mktime(Time.now.year,Time.now.month,Time.now.day) - ((days_ago - 1) * 86400)] }}

  instructors_sql = %Q{
    length(address1) > 0 and
    length(city) > 0 and
    length(state) > 0 and
    length(postal_code) > 0 and
    length(country) > 0 and
    verified_address_on is not null and
    author_agreement_accepted_on is not null and
    payment_level_id is not null
  }

  named_scope :instructors,
              :conditions => instructors_sql

  # Used to verify current password during password changes
  attr_accessor :current_password

  # Used for cropping
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  validates_presence_of :login_count, :failed_login_count, :last_name, :instructor_status, :language
  validates_presence_of :user_agreement_accepted_on #, :message => :must_accept_agreement
  validates_presence_of :login#, :message => :login_required
  validates_uniqueness_of :email, :case_sensitive => false
  validates_uniqueness_of :login, :case_sensitive => false
  validates_numericality_of :login_count, :failed_login_count
  validates_length_of :email, :maximum => 100, :allow_nil => true
  validates_length_of :last_name, :maximum => 40, :allow_nil => true
  validates_length_of :first_name, :maximum => 40, :allow_nil => true
  validates_length_of :login, :maximum => 25, :allow_nil => true
  validates_format_of :login, :with => /\A\S*\z/, :message => "can only consist of letters, numbers and underscores", :allow_nil => true

  DEFAULT_AVATAR_URL = "http://#{APP_CONFIG[CONFIG_AWS_S3_IMAGES_BUCKET]}/users/avatars/missing/%s/missing.png"

  # Paperclip lets you specify custom interpolations for your paths and such. We're going to exploit that!


  Paperclip.interpolates(:gravatar_url) do |attachment, style|
    size = nil
    # style should be :tiny, :small, or :regular
    # size_data is assumed to be "16x16#", "20x20#", or "25x25#", i.e., a string
#    puts "====================>#{style}"
    size_data = attachment.styles[style][:geometry]
    if size_data
      # get the width of the icon in pixels
      if thumb_size = size_data.match(/\d+/).to_a.first
        size = thumb_size.to_i
      end
    end
    # obtain the url from the model
    # replace nil with "identicon", "monsterid", or "wavatar" as desired
    # personally I would reorder the parameters so that size is first
    # and default is second
    attachment.instance.gravatar_url(sprintf(DEFAULT_AVATAR_URL, style), size)
  end

  # PAPERCLIP
  has_attached_file :avatar,
                    :styles => {
                            :tiny => ["35x35#", :png],
                            :smaller => ["60x60#", :png],
                            :small => ["75x75#", :png],
                            :medium => ["110x110#", :png],
                            :large => ["220x220#", :png],
                            :vlarge => ["400x400>", :png]
                    },
                    :default_style => :medium,
                    :default_url => ":gravatar_url",
                    :processors => [:cropper],
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :s3_permissions => 'public-read',
                    :path => "#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/users/:attachment/:id/:style/:basename.:extension",
                    :bucket => APP_CONFIG[CONFIG_AWS_S3_IMAGES_BUCKET]

  # Constructs a gravatar URL from size information. We can pass in a custom default image URL, if we want.
  # This assumes you have an "email" field on your model!
  def gravatar_url(default = "", size = 220)
    hash = Digest::MD5.hexdigest(email.downcase.strip)[0..31]
    "http://www.gravatar.com/avatar/#{hash}.jpg?size=#{size}&d=#{CGI::escape default}"
  end

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

  # From the thinking sphinx doc: Don’t forget to place this block below your associations,
  # otherwise any references to them for fields and attributes will not work.
  define_index do
    indexes login
    indexes bio
    set_property :delta => true
  end

  def self.flag_reasons
    @@flag_reasons
  end

#  def self.default_avatar_url(style)
#    "http://#{APP_CONFIG[CONFIG_AWS_S3_IMAGES_BUCKET]}/users/avatars/missing/%s/missing.png" % style.to_s
#    "/images/users/avatars/%s/missing.png" % style.to_s
#  end

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

  # This method is a decorator and it's sole purpose is to enable memoization
  def is_a_communitymgr?
    self.is_communitymgr?
  end

  memoize :is_a_communitymgr?

  # This method is a decorator and it's sole purpose is to enable memoization
  def is_a_paymentmgr?
    self.is_paymentmgr?
  end

  memoize :is_a_paymentmgr?

  def self.supported_languages
    LANGUAGES
  end

  def students
    sql = <<END
    SELECT distinct u.*
    FROM users AS u
    INNER JOIN credits AS c ON u.id = c.user_id
    INNER JOIN lessons AS l ON c.lesson_id = l.id
    WHERE l.instructor_id = ?
      AND u.active = 1
    ORDER BY u.login
END
    User.find_by_sql([sql, self.id])
  end

  # Reset the password token and then send the user an email
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def self.find_by_login_or_email(login_str, email_str)
    to_user = User.find_by_login(login_str)
    to_user ||= User.find_by_email(email_str)
    to_user
  end

  def follow(instructor)
    instructor.followers << self unless instructor.followed_by?(self)
  end

  def stop_following(instructor)
    instructor.followers.delete(self) if instructor.followed_by?(self)
  end

  # used to verify whether the user typed their correct password when, for example,
  # the user updates their password
  def valid_current_password?
    if valid_password?(current_password.try(:strip))
      true
    else
      errors.add(:current_password, "is incorrect")
      false
    end
  end

  def address_provided?
    not_blank_or_nil(self.address1) and not_blank_or_nil(self.city) and
            not_blank_or_nil(self.state) and not_blank_or_nil(self.postal_code) and
            not_blank_or_nil(self.country)
  end

  # Utility method to return either the last_name if no first name is specified, or the first and last
  # name with a space betwen them
  def full_name
    if first_name.nil? or first_name.empty?
      last_name
    else
      "#{first_name} #{last_name}".strip
    end
  end

  # Has this user purchased this lesson?
  def owns_lesson? lesson
    !self.lessons.scoped_by_id(lesson).first.nil?
  end

  def instructor? lesson
    self == lesson.instructor
  end

  def generate_payment
    payment = self.payments.create(:amount => 0)
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
    if username.blank? and username.blank?
      'Firehoze member'
    elsif self.show_real_name
      full_name.titleize
    else
      username.titleize
    end
  end

  def username
    login
  end

  def self.notify_instructor_signup user_id
    user = User.find(user_id)
    unless user.instructor_signup_notified_at.present?
      Notifier.deliver_instructor_sign_up(user)
      user.update_attribute(:instructor_signup_notified_at, Time.now)
    end
  end

  def self.notify_email_changed user_id
    user = User.find(user_id)
    Notifier.deliver_email_changed(user)
  end

  def can_edit? current_user
    (current_user and (current_user.is_an_admin? or current_user.is_a_moderator?))
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
    klass = Comment if flaggable.class.to_s == "LessonComment" or flaggable.class.to_s == "TopicComment"
    flaggings.by_flaggable_type(klass).find_all_by_flaggable_id(flaggable.id)
  end

  # Has this user specified by the parameter bought of this this user's lessons'
  def student_of?(user)
    user.lessons.collect(&:instructor).include?(self) if user
  end


  # Can the user parameter contact this user via email?
  def can_contact?(user)
    active and (allow_contact == USER_ALLOW_CONTACT_ANYONE or
            (allow_contact == USER_ALLOW_CONTACT_STUDENTS_ONLY and student_of?(user)))
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

  def following?(instructor)
    self.followed_instructors.find_by_id(instructor, :select => [:id])
  end

  def compile_activity
    self.activities.create!(:actor_user => self,
                            :actee_user => nil,
                            :acted_upon_at => self.created_at,
                            :group => nil,
                            :activity_string => "user.activity",
                            :activity_object_id => self.id,
                            :activity_object_human_identifier => self.login,
                            :activity_object_class => self.class.to_s)
    self.update_attribute(:activity_compiled_at, Time.now)
  end

  def compile_instructor_activity
    unless self.instructor_signup_notified_at.nil?
      self.activities.create!(:actor_user => self,
                              :actee_user => nil,
                              :acted_upon_at => self.instructor_signup_notified_at,
                              :group => nil,
                              :activity_string => "user.instructor_activity",
                              :activity_object_id => self.id,
                              :activity_object_human_identifier => self.login,
                              :activity_object_class => self.class.to_s)
      self.update_attribute(:instructor_activity_compiled_at, Time.now)
    end
  end

  # Are we currently cropping the graphic (see Railcasts episode #182)
  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.url(style))
  end

  private

  def strip_fields
    self.login = self.login.strip if self.login
  end

  def round_to_penny amount
    amount = (amount * 100.0).floor
    amount/100.0
  end

  def not_blank_or_nil field
    !field.nil? and !field.blank?
  end

  def reprocess_avatar
    avatar.reprocess!
  end
end