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
end
