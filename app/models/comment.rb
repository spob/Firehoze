class Comment < ActiveRecord::Base
  belongs_to :user
  validates_presence_of     :user, :body

  @@flag_reasons = [
          FLAG_LEWD,
          FLAG_SPAM,
          FLAG_OFFENSIVE ]

  def self.flag_reasons
    @@flag_reasons
  end
  
  def can_edit? user
    user.try("is_moderator?")
  end
end
