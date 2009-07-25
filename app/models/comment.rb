class Comment < ActiveRecord::Base
  belongs_to :user
  validates_presence_of     :user, :body

  def can_edit? user
    user.try("is_moderator?")
  end
end
