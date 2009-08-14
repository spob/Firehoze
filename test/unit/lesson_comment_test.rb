require 'test_helper'

class LessonCommentTest < ActiveSupport::TestCase
  context "given an existing record for a lesson comment" do
    setup { @lesson_comment = Factory.create(:lesson_comment) }

    should_belong_to :lesson
    should_validate_presence_of      :lesson
    should_have_many :flags

    context "and another private record" do
      setup do
        assert !@lesson_comment.nil?
        assert !@lesson_comment.lesson.nil?
        @user = Factory.create(:user)
        @private_comment = Factory.create(:lesson_comment, :lesson => @lesson_comment.lesson, :public => false)
      end

      should "retrieve last comment" do
        assert_equal @private_comment, @lesson_comment.lesson.last_comment
        assert_equal @lesson_comment, @lesson_comment.lesson.last_public_comment

        assert @private_comment.last_comment?
        assert !@private_comment.last_public_comment?
        assert !@lesson_comment.last_comment?
        assert @lesson_comment.last_public_comment?
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

        should "allow moderator to edit the last record" do
          assert @private_comment.can_edit?(@user)
          assert !@private_comment.can_edit?(@private_comment.user)
          assert !@private_comment.can_edit?(Factory.create(:user))
        end
      end

      context "and one more comment which is public" do
        setup do
          @nobody_user = Factory.create(:user)
          assert !@nobody_user.is_moderator?
          @public_comment = Factory.create(:lesson_comment, :lesson => @lesson_comment.lesson)
        end

        should "allow editing for author" do
          assert @public_comment.can_edit?(@public_comment.user)
          assert !@public_comment.can_edit?(@nobody_user)
        end
      end
    end
  end
end
