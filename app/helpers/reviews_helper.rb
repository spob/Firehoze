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
    if lesson.reviews.empty? and ok_to_review?(lesson, user)
      "Be the first to leave a review for this lesson -- #{link_to_review(lesson, user)} "
    elsif user and lesson.reviews.empty? and ok_to_review?(lesson, user)
      "#{link_to_review(lesson, user)}<p>We'd love to hear what you thought about this lesson.</p>"
    elsif ok_to_review?(lesson, user)
      link_to_review(lesson, user)
    end
  end

  def ok_to_review?(lesson, user)
    (!lesson.reviewed_by?(user) and !lesson.instructed_by?(user))
  end
end
