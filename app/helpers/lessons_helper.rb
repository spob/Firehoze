module LessonsHelper
  def watch_text lesson
    if current_user.nil? or current_user.owns_lesson? lesson or current_user == lesson.instructor
      "Watch Lesson"
    elsif lesson.free_credits.available.size > 0
       "Watch For Free" 
    else
      "Acquire Lesson"
    end
  end
end
