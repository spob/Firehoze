module ReviewsHelper
  def show_all_reviews_link(lesson, user)
    review_list_count = Review.list_count(lesson, user)
    if review_list_count > REVIEWS_ON_LESSON_SHOW_PER_PAGE
      link_to "See all #{pluralize(review_list_count, 'Customer Review')}", lesson_reviews_path(lesson, :per_page => ROWS_PER_PAGE)
    else
      ""
    end
  end

  def show_review_text(lesson, user)
    if lesson.show_review_button?(user)
      if lesson.reviews.empty?
        "<div class='info with-button'>Help the Firehoze community by being the first to review this how to.#{link_to_review(lesson, user)}</div>"
      else
        link_to_review(lesson, user)
      end
    elsif lesson.reviews.empty?
      "<div class='info'>Looks like no one has reviewed this lesson yet.</div>"
    end
  end
end
