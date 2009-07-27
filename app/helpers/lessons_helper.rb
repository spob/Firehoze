module LessonsHelper
  def watch_text lesson
    if current_user.nil? or current_user.owns_lesson?(lesson) or current_user == lesson.instructor
      "Watch Lesson"
    elsif lesson.free_credits.available.size > 0
      "Watch For Free" 
    else
      "Buy Lesson"
    end
  end

  # Not sure how to handle this with i18n???
  def free_remaining_text lesson
    if lesson.free_credits?
      "#{pluralize(lesson.free_credits.available.size, 'Free View')} Remaining" 
    end
  end

  def lesson_rating_for(lesson, user, *args)
    ratings_for(lesson, (user != lesson.instructor and lesson.owned_by?(user)) ? :active : :static, *args)
  end

  def lessons_header(collection, *args)
    if controller.action_name == 'list'
      header = case collection
      when :most_popular
        t('lesson.most_popular')
      when :highest_rated
        t('lesson.highest_rated')
      when :newest
        t('lesson.newest')
      when :recently_browsed
        t('lesson.recently_browsed')
      when :owned_lessons
        t('lesson.owned_lessons')
      when :tagged_with
        "#{t('lesson.tagged_with')} &quot;#{args.first}&quot;"
      end
      "<h3>#{header}</h3>"
    end
  end

  def img_tag_lesson_tn(lesson)
    if lesson.thumbnail_url
      link_to(image_tag(lesson.thumbnail_url,:size => "136x91"), lesson_path(lesson))
    else
      link_to(image_tag("videos/video_placeholder.jpg",:size => "136x91"), lesson_path(lesson))
    end
  end

  def number_of_students_phrase(lesson)
    if lesson.credits_count
      "#{t('lesson.students')}: #{lesson.credits_count}"
    elsif lesson.created_at > 7.days.ago
      t('lesson.new_release')
    end
  end

  def owned_it_phase(lesson)
    if current_user and current_user.owns_lesson?(lesson)
      t('lesson.owned')
    end
  end

end
