class Review < ActiveRecord::Base
  belongs_to :user
  belongs_to :lesson, :counter_cache => true
  has_many :helpfuls, :dependent => :destroy
  validates_presence_of :user, :title, :body, :lesson
  validates_uniqueness_of :user_id, :scope => :lesson_id
  validates_length_of :title, :maximum => 100, :allow_nil => true
  validate :validate_reviewer

# Basic paginated listing finder
  def self.list(lesson, page)
    paginate :page => page,
             :conditions => { :lesson_id => lesson }, :order => 'id desc',
             :per_page => Constants::ROWS_PER_PAGE
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
end