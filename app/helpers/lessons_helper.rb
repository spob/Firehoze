module LessonsHelper
  def watch_text lesson
    if current_user.nil? or current_user.owns_lesson? lesson
      "Watch Lesson"
    else
      "Acquire Lesson"
    end
  end
end
