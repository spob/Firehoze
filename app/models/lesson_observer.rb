class LessonObserver < ActiveRecord::Observer
  def after_update(lesson)
    if lesson.activity_compiled_at.nil? and lesson.ready?
      Lesson.transaction do
        lesson.compile_activity
      end
      RunOncePeriodicJob.create!(
              :name => 'Post New Lesson to Facebook',
              :job => "FacebookPublisher.deliver_new_lesson(#{lesson.id})") if lesson.instructor.session_key
    end
  end
end