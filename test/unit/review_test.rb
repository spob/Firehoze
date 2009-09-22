require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class ReviewTest < ActiveSupport::TestCase

  fast_context "given a user and a credit" do
    setup do
      @user = Factory.create(:user)
      @lesson = Factory.create(:lesson)
      @user.credits.create!(:price => 0.99, :lesson => @lesson, :acquired_at => Time.now,
                            :line_item => Factory.create(:line_item))
    end

    fast_context "and a review with no rating" do
      setup do
        @review = Factory.build(:review, :user => @user, :lesson => @lesson)
      end

      should 'fail validation' do
        assert !@review.valid?
        assert_equal "In order to review a lesson, please rate it first", @review.errors.on("base")
      end
    end

    # cannot use fast_context
    context "given an existing review" do
      setup do
        @rate = @lesson.rates.create!
        # user id isn't set above because of protection from mass assignment
        @rate.update_attribute(:user_id, @user.id)
        assert_equal @lesson, @lesson.rates.first.rateable
        assert_equal @user, @lesson.rates.first.user
        @review = Factory.create(:review, :user => @user, :lesson => @lesson)
        assert @user.owns_lesson?(@lesson)
      end

      should_belong_to :user
      should_belong_to :lesson
      should_have_many :helpfuls, :flags
      should_validate_presence_of :user, :headline, :body, :lesson
      should_allow_values_for    :status, "active", "rejected"
      should_validate_uniqueness_of :user_id, :scoped_to => :lesson_id
      should_ensure_length_in_range :headline, (0..100)
      should_not_allow_mass_assignment_of :status, :helpfuls, :flags

      should "return records" do
        assert_equal 1, Review.list(@review.lesson, 1, @user, REVIEWS_ON_LESSON_SHOW_PER_PAGE).size
        assert_equal 1, Review.list_count(@review.lesson, @user)
        assert_equal 1, Review.ready.size
      end

      should "not be reviewed" do
        assert_nil @review.helpful?(Factory.create(:user))
      end

      fast_context "when rejecting" do
        setup do
          assert_equal @review.status, REVIEW_STATUS_ACTIVE
          @review.reject
          @review.save
        end

        should "be rejected" do
          assert_equal @review.status, REVIEW_STATUS_REJECTED
        end
      end

      fast_context "that was marked as helpful by a user" do
        setup do
          @user2 = Factory.create(:user)
          @review.helpfuls.create!(:user => @user2, :helpful => true)
        end

        should "be helpful" do
          assert @review.helpful?(@user2)
        end

        fast_context "that was marked as not helpful by a user" do
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

   fast_context "give a lesson and user" do
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
end