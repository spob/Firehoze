require 'test_helper'

class ReviewTest < ActiveSupport::TestCase

  context "given an existing review" do
    setup do
      @review = Factory.create(:review)
    end

    should_belong_to :user
    should_belong_to :lesson
    should_have_many :helpfuls
    should_validate_presence_of :user, :title, :body, :lesson
    should_validate_uniqueness_of :user_id, :scoped_to => :lesson_id
    should_ensure_length_in_range :title, (0..100)

    should "return records" do
      assert_equal 1, Review.list(@review.lesson, 1).size
    end

    should "not be reviewed" do
      assert_nil @review.helpful?(Factory.create(:user))
    end

    context "that was marked as helpful by a user" do
      setup do
        @user = Factory.create(:user)
        @review.helpfuls.create(:user => @user, :helpful => true)
      end

      should "be helpful" do
        assert @review.helpful?(@user)
      end

      context "that was marked as not helpful by a user" do
        setup do
          @user = Factory.create(:user)
          @review.helpfuls.create(:user => @user, :helpful => false)
        end

        should "be helpful" do
          assert !@review.helpful?(@user)
        end
      end
    end
  end
end