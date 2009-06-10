class Registration < ActiveUrl::Base  
  attribute :email, :accessible => true
  attribute :login,  :accessible => true
  attribute :first_name,  :accessible => true
  attribute :last_name,  :accessible => true
  attribute :time_zone,  :accessible => true
  attribute :language,  :accessible => true
  attribute :password,  :accessible => true
  attribute :password_confirmation,  :accessible => true

  validate :account_not_taken
  validate :password_matches
  validates_format_of :email, :with => /^[\w\.=-]+@[\w\.-]+\.[a-zA-Z]{2,4}$/ix, :allow_nil => true
  validates_presence_of :email, :language, :last_name, :login, :password, :password_confirmation
  validates_length_of       :email, :maximum => 100, :allow_nil => true
  validates_length_of       :last_name, :maximum => 40, :allow_nil => true
  validates_length_of       :first_name, :maximum => 40, :allow_nil => true
  validates_length_of       :login, :maximum => 25, :allow_nil => true

  after_save :send_registration_email

  protected

  def account_not_taken
    if User.find_by_email(email)
      errors.add(:email, "is already in use")
    end
    if User.find_by_login(login)
      errors.add(:login, "is already in use")
    end
  end

  def password_matches
    if !password.try(:empty?) and !password_confirmation.try(:empty?) and password != password_confirmation
      errors.add(:password, "does not match password confirmation")      
    end
  end

  def send_registration_email
    Notifier.deliver_registration(self)
  end
end