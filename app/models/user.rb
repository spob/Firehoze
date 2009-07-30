# As its name implies, a user is a authorized user of the site. It contains information about the user
# (for example, first and last name), their encrypted password, etc.
class User < ActiveRecord::Base
  # Ajaxful-rating plugin
  ajaxful_rater

  # Authorization plugin
  acts_as_authorized_user

  before_save :persist_user_logon

  acts_as_authentic  do |c|
    c.logged_in_timeout = 30.minutes # log out after 30 minutes of inactivity
  end

  has_many :user_logons, :order => "created_at DESC", :dependent => :destroy
  has_many :credits, :order => 'id', :dependent => :destroy
  has_many :gift_certificates, :dependent => :destroy
  has_many :orders, :order => 'id DESC', :dependent => :destroy
  has_many :visited_lessons, :source => :lesson, :through => :lesson_visits, :order => 'visited_at DESC'
  has_many :lesson_visits, :order => 'visited_at DESC', :dependent => :destroy
  has_many :available_credits, :class_name => 'Credit',
           :conditions => { :redeemed_at => nil },
           :order => "id"
  # Lessons represents lessons that this user has "bought"
  has_many :instructed_lessons, :class_name => 'Lesson', :foreign_key => 'instructor_id'
  has_many :lessons, :through => :credits
  has_many :reviews, :dependent => :destroy
  has_many :helpfuls, :dependent => :destroy
  has_and_belongs_to_many :wishes, :join_table => 'wishes', :class_name => 'Lesson'

  # Active users
  named_scope :active, :conditions => {:active => true}

  # Used to verify current password during password changes
  attr_accessor :current_password

  validates_presence_of     :email, :language,
                            :login_count, :failed_login_count, :last_name
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
    :small => ["35x35#", :png],
    :medium => ["75x75#", :png],
    :large => ["220x220#", :png]
  },
    :storage => :s3,
    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
    :s3_permissions => 'public-read',
    :path => "#{APP_CONFIG[CONFIG_S3_DIRECTORY]}/:attachment/:id/:basename.:extension",
    :bucket => APP_CONFIG[CONFIG_AWS_S3_IMAGES_BUCKET],
    :default_url => "users/avatars/medium/missing.png"
  # :url => "/assets/avatars/:id/:basename.:extension",
  # :path => ":rails_root/public/assets/avatars/:id/:basename.:extension",
  validates_attachment_size :avatar, :less_than => 3.megabytes, :message => "All uploaded images must be less then 3 megabytes"
  validates_attachment_content_type :avatar, :content_type => [ 'image/gif', 'image/png', 'image/x-png', 'image/jpeg', 'image/pjpeg', 'image/jpg' ]

  attr_protected :email, :login

  # keep, may use this 
  # def self.default_avatar_url(style)
  #   "http://#{PAPERCLIP_BUCKET}/users/avatars/%s/missing.jpg" % style.to_s
  # end

  def self.admins
    Role.find_by_name('admin').users
  end

  def self.supported_languages
    LANGUAGES
  end

  # Reset the password token and then send the user an email
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  # Basic paginated listing finder
  def self.list(page)
    paginate :page => page, :order => 'email',
             :per_page => ROWS_PER_PAGE
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

  def city_and_state
    [ city, state ].reject { |e| e.blank? }.join(', ')
  end
  
  def handle_or_name
    return 'Firehoze member' if handle.blank? and name.blank?
    handle || full_name
  end

  def handle 
    login
  end

  def on_wish_list? lesson
    self.wishes.find_by_id(lesson.id)
  end

  def owned_lessons
    lessons + instructed_lessons
  end

  private

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
end