class LessonComment < Comment
  belongs_to :lesson
  has_many :activities, :as => :trackable, :dependent => :destroy
  validates_presence_of :lesson
  has_many :flags, :as => :flaggable, :dependent => :destroy

# Basic paginated listing finder
  def self.list(lesson, page, current_user=nil, per_page=ROWS_PER_PAGE)
    comments = Comment.numerate(LessonComment.find(:all,
             :conditions => list_conditions(lesson, current_user), :include => [:user, :lesson],
             :order => 'id'))
    comments.paginate :page => page, :per_page => per_page
  end

  def self.list_count(lesson, current_user)
    LessonComment.count(:conditions => list_conditions(lesson, current_user))
  end

  def last_comment?
    self == self.lesson.vlast_comment
  end

  def last_public_comment?
    self == self.lesson.comments(:select => [:id]).last
#    self == self.lesson.vlast_public_comment
  end

  def self.list_conditions(lesson, current_user)
    conditions = { :lesson_id => lesson }
    conditions = conditions.merge!({:public => true, :status => COMMENT_STATUS_ACTIVE}) unless current_user.try(:is_an_admin?) or current_user.try(:is_a_moderator?)
    conditions
  end

  def compile_activity
    self.activities.create!(:actor_user => self.user,
                            :actee_user => self.lesson.instructor,
                            :acted_upon_at => self.created_at,
                            :activity_string => 'lesson_comment.activity',
                            :activity_object_id => self.lesson.id,
                            :activity_object_class => self.lesson.class.to_s,
                            :activity_object_human_identifier => self.lesson.title,
                            :secondary_activity_object_id => nil,
                            :secondary_activity_object_human_identifier => nil,
                            :secondary_activity_object_class => nil)
    self.update_attribute(:activity_compiled_at, Time.now)
  end
end
