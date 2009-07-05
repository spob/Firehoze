require 'test_helper'

class HelpfulTest < ActiveSupport::TestCase
  context "given an existing helpful record" do
    setup do
      @user = Factory.create(:user)
      @lesson = Factory.create(:lesson)
      @user.credits.create!(:price => 0.99, :lesson => @lesson, :acquired_at => Time.now,
                            :line_item => Factory.create(:line_item))
      @review = Factory.create(:review, :user => @user, :lesson => @lesson)
      assert @user.owns_lesson?(@lesson)
      @helpful = Factory.create(:helpful, :review => @review)
    end

    should_validate_presence_of      :review, :user
    should_belong_to                 :review
    should_belong_to                 :user

    context "where the author of the review also provides feedback" do
      setup do
        assert_valid @helpful
        @helpful.user = @helpful.review.user
      end

      should "fail save" do
        assert !@helpful.save
        assert_bad_value(@helpful, :user, @helpful.user, I18n.t('helpful.cant_feedback_own'))

      end
    end

    context "and another that is helpful and one that is not" do
      setup do
        @helpful1 = Factory.create(:helpful, :review => @review)
        @helpful2 = Factory.create(:helpful, :review => @review, :helpful => false)
      end

      should "have 2 yes and 1 no" do
        assert_equal 2, Helpful.helpful_yes.size
        assert_equal 1, Helpful.helpful_no.size
      end
    end
  end
end
