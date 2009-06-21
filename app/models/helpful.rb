# A helpful record indicates whether or not a user found a particular review helpful. The
# helpful models maps a user to a review and has a flag which, if true, indicates the user
# found the review helpful and if false, they did not find it helpful
class Helpful < ActiveRecord::Base
  belongs_to :user
  belongs_to :review

  validates_presence_of :user, :review
  validate :not_author

  named_scope :helpful_yes, :conditions => { :helpful => true }
  named_scope :helpful_no, :conditions => { :helpful => false }

  protected

  def not_author
    if review and self.review.user == self.user
      errors.add(:user, I18n.t('helpful.cant_feedback_own'))
    end
  end
end
