module LessonCommentsHelper

  def show_all_lesson_comments_link(lesson, user)
    comments_list_count = LessonComment.list_count(lesson, user)
    if comments_list_count > COMMENTS_ON_LESSON_SHOW_PER_PAGE
      link_to "See all #{pluralize(comments_list_count, 'Comments')}",
              lesson_lesson_comments_path(lesson)
    else
      ""
    end
  end

  def show_discussion_text(lesson)
    if lesson.comments.empty?
      "<div class='info with-button'>Discussions allow you to interact with the coach and with other individuals.<br />You can ask a question or comment on this lesson.
      #{link_to_comment(lesson, 'Start the Discussion')}
      </div>"
    else
      link_to_comment(lesson, "Post a Reply")
    end
  end
end
