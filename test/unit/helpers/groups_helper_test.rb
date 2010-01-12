require File.dirname(__FILE__) + '/../../test_helper'

class GroupsHelperTest < ActionView::TestCase
  tests GroupsHelper

  context "given a user and a group" do
    setup do
      @user = Factory.create(:user)
      @group = Factory.create(:group)
    end

    should "not show invite link" do
      assert show_invite_link(@group, @user).nil?
    end

    should "note show edit link" do
      assert show_edit_link(@group, @user).nil?
    end

    should "show not a member" do
      assert_match /are not a member/, show_membership_text(@group, @user)
      assert_match /not logged in/, show_membership_text(@group, nil)
    end

    context "and with user as owner" do
      setup do
        @group_member = GroupMember.create!(:user => @user, :group => @group, :member_type => OWNER)
        @group.reload
        @group.update_attribute(:owner, @user)
      end

      should "show owner" do
        assert_match /owner/, show_membership_text(@group, @user)
      end

      should "not show invite link" do
        assert show_invite_link(@group, @user).nil?
      end

      should "show edit link" do
        assert_match /Edit/, show_edit_link(@group, @user)
      end

      context "and group is private" do
        setup { @group.update_attribute(:private, true) }

        should "show invite link" do
          assert_match /Invite/, show_invite_link(@group, @user)
        end
      end
    end

    context "and with user as moderator" do
      setup do
        @group_member = GroupMember.create!(:user => @user, :group => @group, :member_type => MODERATOR)
      end

      should "show moderator" do
        assert_match /moderator/, show_membership_text(@group, @user)
      end

      should "not show invite link" do
        assert show_invite_link(@group, @user).nil?
      end

      context "and group is private" do
        setup do
          @group.reload
          @group.update_attribute(:private, true)
        end

        should "show invite link" do
          assert_match /Invite/, show_invite_link(@group, @user)
        end
      end

      context "and another group member" do
        setup { @group_member1 = GroupMember.create!(:user => Factory.create(:user), :group => @group, :member_type => MEMBER) }

        should "show member" do
          assert_match /member/, show_membership_text(@group, @group_member1.user)
        end

        should "not sure remove link for a non-member" do
          assert show_remove_link(@group_member, @user).nil?
          assert show_remove_link(@group_member, nil).nil?
        end

        context "and group is private" do
          setup do
            @group.reload
            @group.update_attribute(:private, true)
          end

          should "show remove link" do
            assert_match /Remove/, show_remove_link(@group_member1, @user)
          end
        end

      end
    end

    should "show join link" do
      assert_match /Join/, show_join_link(@group, @user)
      assert_match /Join/, show_join_link(@group, nil)
    end

    should "not show leave link" do
      assert show_leave_link(@group, @user).nil?
      assert show_leave_link(@group, nil).nil?
    end

    context "and user is a member" do
      setup { @group_member = GroupMember.create!(:user => @user, :group => @group, :member_type => MEMBER) }

      should "not show join link" do
        assert show_join_link(@group, @user).nil?
      end

      should "show leave link" do
        assert_match /Leave/, show_leave_link(@group, @user)
      end
    end

    context "and group is private" do
      setup { @group.update_attribute(:private, true) }

      should "not show join link" do
        assert show_join_link(@group, @user).nil?
      end

      should "not show leave link" do
        assert show_leave_link(@group, @user).nil?
      end
    end
  end

  private

  # to prevent undefined method when forms are involved
  def protect_against_forgery?
    false
  end

end
