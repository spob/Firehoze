# As its name implies, a user is a authorized user of the site. It contains information about the user
# (for example, first and last name), their encrypted password, etc.
class User < ActiveRecord::Base
  # Authorization plugin
  acts_as_authorized_user

  before_save :persist_user_logon

  acts_as_authentic  do |c|
    c.logged_in_timeout = 30.minutes # log out after 30 minutes of inactivity   
  end

  has_many :user_logons, :order => "created_at DESC", :dependent => :destroy
  has_many :credits, :dependent => :destroy

  # Used to verify current password during password changes
  # todo: I don't think the first and last name accessors are necessary because they are persist fields. Joel? --RBS
  attr_accessor :current_password, :first_name, :first_name

  validates_presence_of :email, :language,
                        :login_count, :failed_login_count, :last_name, :login
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_uniqueness_of   :login, :case_sensitive => false
  validates_numericality_of :login_count, :failed_login_count
  validates_length_of       :email, :maximum => 100, :allow_nil => true
  validates_length_of       :last_name, :maximum => 40, :allow_nil => true
  validates_length_of       :first_name, :maximum => 40, :allow_nil => true
  validates_length_of       :login, :maximum => 25, :allow_nil => true

  attr_protected :email, :login

  # @@languages hold a list of languages that the user can choose from when setting up their account
  # information...it is used to populate the html select
  @@languages = [
          ['English', 'en'],
          ['Wookie', 'wk']
  ]

  def self.supported_languages
    @@languages
  end

  # Reset the password token and then send the user an email
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  # Basic paginated listing finder
  def self.list(page)
    paginate :page => page, :order => 'email',
             :per_page => Constants::ROWS_PER_PAGE
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
    return last_name if first_name.empty?
    "#{first_name} #{last_name}"
  end

  private

  def persist_user_logon
    # Surprisingly AuthLogic doesn't provide a clean callback for detecting when a login occurs...so instead,
    # watch for when the login count is incremented (which is done by AuthLogic).
    UserLogon.create(:user => self,
                     :login_ip => self.current_login_ip) if login_count > login_count_was
  end
end