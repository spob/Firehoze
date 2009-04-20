class User < ActiveRecord::Base
  acts_as_authentic  do |c|
    c.logged_in_timeout = 30.minutes # log out after 30 minutes of inactivity   
  end

  validates_presence_of :email, :crypted_password, :password_salt, :persistence_token,
          :perishable_token, :login_count, :failed_login_count
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_numericality_of :login_count, :failed_login_count
  validates_length_of       :email, :maximum => 100, :allow_nil => true

  # Reset the password token and then send the user an email
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def self.list(page)
    paginate :page => page, :order => 'email',
            :per_page => 25
  end
end