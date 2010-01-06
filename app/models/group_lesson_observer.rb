class GroupLessonObserver < ActiveRecord::Observer
  def after_create(group_lesson)
    if group_lesson.activity_compiled_at.nil? and group_lesson.active
      GroupLesson.transaction do
        group_lesson.compile_activity
      end
    end
  end
end
