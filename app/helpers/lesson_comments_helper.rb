module LessonCommentsHelper

  def show_all_lesson_comments_link(lesson, user)
    comments_list_count = LessonComment.list_count(lesson, user)
    if comments_list_count > COMMENTS_ON_LESSON_SHOW_PER_PAGE
      link_to "See all #{pluralize(comments_list_count, 'Comments')}",
              lesson_lesson_comments_path(lesson, :per_page => ROWS_PER_PAGE)
    else
      ""
    end
  end

  def show_discussion_text lesson, lesson_comments, user
    if lesson_comments.empty? and lesson.owned_by?(user)
      "Need some help? #{link_to_comment(lesson, 'Ask a question')}"
    elsif lesson.can_comment?(user)
      link_to_comment(lesson, "Post a reply")
    elsif user
      t('lesson.must_own')
    else
      "You must #{link_to 'login', login_path} or #{link_to 'register', new_registration_path} to contribute to this discussion."
    end
  end

  def show_discussion_text_2(lesson, user)
    if lesson.comments.empty? and lesson.owned_by?(user)
      "Need some help? #{link_to_comment(lesson, 'Ask a question')}"
    elsif lesson.can_comment?(user)
      link_to_comment(lesson, "Post a reply")
    elsif current_user
      t('lesson.must_own')
    else
      "You must #{link_to 'login', login_path} or #{link_to 'register', new_registration_path} to contribute to this discussion."
    end
  end

  def show_discussion_text_3(lesson, user)
    if lesson.can_comment?(user)
      if lesson.comments.empty?
        "Need some help? #{link_to_comment(lesson, 'Ask a question')}"
      else
        link_to_comment(lesson, "Post a reply")
      end
    else
      t('lesson.must_own')
    end
  end
end
