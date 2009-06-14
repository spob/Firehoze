# A registration is a request by a user for an account. This value is not persisted in the database. Rather,
# the information is encrypted into a URL using the ActiveUrl plugin, which is sent to the user in the form
# of an email. The user then clicks on the URL to confirm their information, thereby verifying that the user's
# email is a valid email.
#
# To read more about the ActiveUrl plugin, and the address confirmation logic, read:
# http://github.com/mholling/active_url/tree/master
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

  # Verify that this email and logic have not been taken before
  def account_not_taken
    if User.find_by_email(email)
      errors.add(:email, "is already in use")
    end
    if User.find_by_login(login)
      errors.add(:login, "is already in use")
    end
  end

  def send_registration_email
    # ActiveURL has a callback mechanism, but it doesn't differentiate between creation and update. So, the
    # controller will set the send_mail flag explicitly on creation so that the user will receive the email
    # in that case, but not on any other subsequent updates (which don't set the flag)
    Notifier.deliver_registration(self) if send_email
  end
end