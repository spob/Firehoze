class LessonComment < Comment
  belongs_to :lesson
  validates_presence_of :lesson

# Basic paginated listing finder
  def self.list(lesson, page, current_user=nil)
    conditions = { :lesson_id => lesson }
    conditions = conditions.merge({:public => true}) unless (current_user and current_user.is_moderator?)
    paginate :page => page,
             :conditions => conditions, :order => 'id desc',
             :per_page => ROWS_PER_PAGE
  end
end
