class User < ActiveRecord::Base
  acts_as_authentic  do |c|
    c.logged_in_timeout = 30.minutes # log out after 30 minutes of inactivity   
  end

  # Reset the password token and then send the user an email
  def deliver_password_reset_instructions!
    reset_perishable_token!    
    Notifier.deliver_password_reset_instructions(self)
  end
end