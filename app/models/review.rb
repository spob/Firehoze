class Review < ActiveRecord::Base
  before_validation_on_create :default_values
  
  belongs_to :user
  belongs_to :lesson, :counter_cache => true
  has_many :helpfuls, :dependent => :destroy
  has_many :flags, :as => :flaggable, :dependent => :destroy
  validates_presence_of :user, :headline, :body, :lesson, :status
  validates_inclusion_of :status, :in => %w{ active rejected }
  validates_uniqueness_of :user_id, :scope => :lesson_id
  validates_length_of :headline, :maximum => 100, :allow_nil => true
  validate :validate_reviewer
  
  attr_protected :status

  @@flag_reasons = [
          FLAG_LEWD,
          FLAG_SPAM,
          FLAG_OFFENSIVE ]

  def self.flag_reasons
    @@flag_reasons
  end

# Basic paginated listing finder
  def self.list(lesson, page, current_user)
    conditions = { :lesson_id => lesson }
    conditions = conditions.merge({ :status => REVIEW_STATUS_ACTIVE}) unless (current_user and current_user.is_moderator?)
    paginate :page => page,
             :conditions => conditions, :order => 'id desc',
             :per_page => ROWS_PER_PAGE
  end

  # The review can be edited by a moderator
  def can_edit? user
    user and user.is_moderator?
  end

  # Was this review marked as helpful by this user. Will return true if it was helpful, false if it wasn't,
  # and nil if it hasn't received this users feedback
  def helpful? user
    self.helpfuls.scoped_by_user_id(user).first.try(:helpful)
  end

  def reject
    self.status = REVIEW_STATUS_REJECTED
  end

  private

  def validate_reviewer
    # Instructor can't review their own video'
    if self.lesson and self.lesson.instructor == self.user
      errors.add_to_base(I18n.t('review.cannot_review_own_lesson'))
    end
    # Must have viewed the video to review it
    if self.user and !self.user.owns_lesson? self.lesson
      errors.add_to_base(I18n.t('review.must_view_to_review'))
    end
  end

  def default_values
    self.status = REVIEW_STATUS_ACTIVE
  end
end