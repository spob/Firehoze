require File.dirname(__FILE__) + '/../../test_helper'

class ReviewsHelperTest < ActionView::TestCase
  context "with a lesson defined" do
    setup do
      @lesson = Factory.create(:lesson)
      @user = Factory.create(:user)
      @user.credits.create!(:price => 0.99, :lesson => @lesson, :acquired_at => Time.now,
                            :line_item => Factory.create(:line_item))
      assert @lesson.owned_by?(@user)
      @rate = @lesson.rates.create!
      # user id isn't set above because of protection from mass assignment
      @rate.update_attribute(:user_id, @user.id)
      assert_equal @lesson, @lesson.rates.first.rateable
      assert_equal @user, @lesson.rates.first.user
      @review = Factory.create(:review, :user => @user, :lesson => @lesson)
    end

    should "return empty link" do
      assert_equal "", show_all_reviews_link(@lesson, nil)
    end
  end
end
