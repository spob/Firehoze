require 'test_helper'

class LessonCommentTest < ActiveSupport::TestCase
  context "given an existing record for a lesson comment" do
    setup { @lesson_comment = Factory.create(:lesson_comment) }

    should_belong_to :lesson
    should_validate_presence_of      :lesson

    context "and another private record" do
      setup do
        assert !@lesson_comment.nil?
        assert !@lesson_comment.lesson.nil?
        @user = Factory.create(:user)
        @private_comment = Factory.create(:lesson_comment, :lesson => @lesson_comment.lesson, :public => false)
      end

      should "retrieve public records only" do
        assert_equal 1, LessonComment.list(@lesson_comment.lesson, 1).size
        assert_equal 1, LessonComment.list(@lesson_comment.lesson, 1, @user).size
      end

      context "and a user who is a moderator" do
        setup { @user.is_moderator }

        should "retrieve public and private records" do
          assert_equal 2, LessonComment.list(@lesson_comment.lesson, 1, @user).size
        end
      end
    end
  end
end
