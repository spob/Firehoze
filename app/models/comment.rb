class Comment < ActiveRecord::Base
  belongs_to :user
  before_validation_on_create :default_values
  validates_presence_of     :user, :body, :status
  validates_inclusion_of :status, :in => %w{ active rejected }

  named_scope :public, :conditions => { :public => true }

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

  private

  def default_values
    self.status = COMMENT_STATUS_ACTIVE
  end
end
