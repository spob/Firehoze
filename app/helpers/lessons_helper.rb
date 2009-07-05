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
    ratings_for(lesson, (user != @lesson.instructor and lesson.owned_by?(user)) ? :active : :static)
  end

  def lessons_header(collection)
    if controller.action_name == 'list'
     header = case collection
      when :highest_rated
        "Highest Rated"
      when :newest
        "Newest"
      when :most_popular
        "Most Popular"
      end
      "<h4>#{header}</h4>"
    end
  end
end
