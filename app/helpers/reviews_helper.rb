module ReviewsHelper
  def show_all_reviews_link(lesson, user)
    review_list_count = Review.list_count(lesson, user)
    if review_list_count > REVIEWS_ON_LESSON_SHOW_PER_PAGE
      link_to "See all #{pluralize(review_list_count, 'Customer Review')}",
              lesson_reviews_path(lesson, :per_page => ROWS_PER_PAGE)
    else
      ""
    end
  end
end
