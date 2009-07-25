class LessonComment < Comment
  belongs_to :lesson
  validates_presence_of :lesson

# Basic paginated listing finder
  def self.list(lesson, page)
    paginate :page => page,
             :conditions => { :lesson_id => lesson }, :order => 'id desc',
             :per_page => ROWS_PER_PAGE
  end
end
