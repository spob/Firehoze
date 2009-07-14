require 'test_helper'

class ReviewTest < ActiveSupport::TestCase

  context "given an existing review" do
    setup do
      @user = Factory.create(:user)
      @lesson = Factory.create(:lesson)
      @user.credits.create!(:price => 0.99, :lesson => @lesson, :acquired_at => Time.now,
                            :line_item => Factory.create(:line_item))
      @review = Factory.create(:review, :user => @user, :lesson => @lesson)
      assert @user.owns_lesson?(@lesson)
    end

    should_belong_to :user
    should_belong_to :lesson
    should_have_many :helpfuls
    should_validate_presence_of :user, :headline, :body, :lesson
    should_validate_uniqueness_of :user_id, :scoped_to => :lesson_id
    should_ensure_length_in_range :headline, (0..100)

    should "return records" do
      assert_equal 1, Review.list(@review.lesson, 1).size
    end

    should "not be reviewed" do
      assert_nil @review.helpful?(Factory.create(:user))
    end

    context "that was marked as helpful by a user" do
      setup do
        @user2 = Factory.create(:user)
        @review.helpfuls.create!(:user => @user2, :helpful => true)
      end

      should "be helpful" do
        assert @review.helpful?(@user2)
      end

      context "that was marked as not helpful by a user" do
        setup do
          @user2 = Factory.create(:user)
          @review.helpfuls.create(:user => @user2, :helpful => false)
        end

        should "be helpful" do
          assert !@review.helpful?(@user2)
        end
      end
    end
  end

  context "give a lesson and user" do
    setup do
      @user = Factory.create(:user)
      @lesson = Factory.create(:lesson, :instructor => @user)
      @review = Factory.build(:review, :lesson => @lesson, :user => @user)
    end

    should "review not be valid" do
      # author can't write their own reviews'
      assert !@review.valid?
    end
  end
end