class User < ActiveRecord::Base
  acts_as_authentic

  # Reset the password token and then send the user an email
  def deliver_password_reset_instructions!
    reset_perishable_token!    
    Notifier.deliver_password_reset_instructions(self)
  end
end