class Comment < ActiveRecord::Base
  belongs_to :user
  before_validation_on_create :default_values
  validates_presence_of :user, :body, :status
  validates_inclusion_of :status, :in => %w{ active rejected }

  named_scope :public, :conditions => { :public => true }

  attr_accessor :row_num

  @@flag_reasons = [
          FLAG_LEWD,
          FLAG_SPAM,
          FLAG_OFFENSIVE ]

  def self.flag_reasons
    @@flag_reasons
  end

  def reject
    self.status = COMMENT_STATUS_REJECTED
  end

  def can_edit? user
    (user.try(:is_a_moderator?) or (last_public_comment? and self.user == user)) and (self.public or Comment.show_public_private_option?(user))
  end

  # Display the option of public versus private to the user
  def self.show_public_private_option?(user)
    user and (user.is_an_admin? or user.is_a_moderator?)
  end

  def self.numerate(comments)
    comments.each_with_index { |comment, i| comment.row_num = i + 1 }
  end

  private

  def default_values
    self.status = COMMENT_STATUS_ACTIVE
  end
end
