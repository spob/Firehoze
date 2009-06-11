class Registration < ActiveUrl::Base  
  attribute :email, :accessible => true
  attribute :login,  :accessible => true
  attr_accessor :send_email

  validate :account_not_taken
  validates_format_of :email, :with => /^[\w\.=-]+@[\w\.-]+\.[a-zA-Z]{2,4}$/ix, :allow_nil => true
  validates_presence_of :email, :login
  validates_length_of       :email, :maximum => 100, :allow_nil => true
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

  def send_registration_email
    Notifier.deliver_registration(self) if send_email
  end
end