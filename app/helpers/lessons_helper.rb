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

  def lesson_rating_for(lesson, user)
    ratings_for(lesson, (user != @lesson.instructor and user.owns_lesson?(lesson)) ? :active : :static)
  end

end
