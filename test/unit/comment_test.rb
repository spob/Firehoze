require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  context "given an existing record for a comment" do
    setup { @comment = Factory.create(:comment) }

    should_belong_to :user
    should_validate_presence_of      :user, :body

    context "and invoking can edit" do
      setup { @user = Factory.create(:user) }

      should "not allow editing" do
        assert !@comment.can_edit?(nil)
        assert !@comment.can_edit?(@user)
      end

      context "as a moderator" do
        setup { @user.is_moderator }

        should "allow editing" do
          assert @comment.can_edit?(@user)
        end
      end
    end
  end
end
