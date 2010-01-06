class LessonObserver < ActiveRecord::Observer
  def after_update(lesson)
    if lesson.activity_compiled_at.nil? and lesson.ready?
      Lesson.transaction do
        lesson.compile_activity
      end
    end
  end
end