class ReviewObserver < ActiveRecord::Observer
  def after_create(review)
    if review.activity_compiled_at.nil?
      Review.transaction do
        review.compile_activity
      end
    end
  end
end
