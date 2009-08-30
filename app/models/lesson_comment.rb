class LessonComment < Comment
  belongs_to :lesson
  validates_presence_of :lesson
  has_many :flags, :as => :flaggable, :dependent => :destroy

# Basic paginated listing finder
  def self.list(lesson, page, current_user=nil)
    paginate :page => page,
             :conditions => list_conditions(lesson, current_user), :order => 'id desc',
             :per_page => ROWS_PER_PAGE
  end

  def self.list_count(lesson, current_user)
    LessonComment.count(:conditions => list_conditions(lesson, current_user))
  end

  def last_comment?
    self == self.lesson.vlast_comment
  end

  def last_public_comment?
    self == self.lesson.vlast_public_comment
  end

  def can_edit? user
    super or (self.last_public_comment? and self.user == user)
  end

  def self.list_conditions(lesson, current_user)
    conditions = { :lesson_id => lesson }
    conditions = conditions.merge!({:public => true, :status => COMMENT_STATUS_ACTIVE}) unless (current_user and current_user.is_moderator?)
    conditions
  end
end
