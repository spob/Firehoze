require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class CommentTest < ActiveSupport::TestCase
  fast_context "given an existing record for a comment" do
    setup { @comment = Factory.create(:lesson_comment) }
    subject { @comment }

    should_belong_to :user
    should_validate_presence_of      :user, :body
    should_allow_values_for    :status, "active", "rejected"
    #should_not_allow_values_for    :status, "blah"

    fast_context "when rejecting" do
      setup do
        assert_equal @comment.status, COMMENT_STATUS_ACTIVE
        @comment.reject
        @comment.save
      end

      should "be rejected" do
        assert_equal @comment.status, COMMENT_STATUS_REJECTED
      end
    end

    fast_context "and invoking can edit" do
      setup { @user = Factory.create(:user) }

      should "not allow editing" do
        assert !@comment.can_edit?(nil)
        assert !@comment.can_edit?(@user)
      end

      fast_context "as a moderator" do
        setup { @user.is_moderator }

        should "allow editing" do
          assert @comment.can_edit?(@user)
        end
      end
    end
  end
end
