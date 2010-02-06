require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class GroupMemberTest < ActiveSupport::TestCase
  fast_context "with a group defined" do
    setup do
      @group = Factory.create(:group)
      @group_moderator = GroupMember.create!(:user => Factory.create(:user), :group => @group, :member_type => MODERATOR)
      @group_member = GroupMember.create!(:user => Factory.create(:user), :group => @group, :member_type => MEMBER)
      @group_pending = GroupMember.create!(:user => Factory.create(:user), :group => @group, :member_type => PENDING)
    end
    subject { @group_member }

    should_have_many :activities
    should_belong_to :group
    should_belong_to :user

    fast_context "compile_activity" do
      should "generate activity records" do
        assert_equal @group_moderator, @group_moderator.activities.first.trackable
        assert_equal @group_member, @group_member.activities.first.trackable
        assert @group_pending.activities.empty?
      end
    end

    should "verify owners and moderators can edit" do
      assert @group_member.can_edit?(@group.owner)
      assert @group_moderator.can_edit?(@group.owner)
      assert @group_pending.can_edit?(@group.owner)

      assert @group_member.can_edit?(@group_moderator.user)
      assert !@group_moderator.can_edit?(@group_moderator.user)
      assert @group_pending.can_edit?(@group_moderator.user)

      assert !@group_member.can_edit?(@group_member.user)
      assert !@group_moderator.can_edit?(@group_member.user)
      assert !@group_pending.can_edit?(@group_member.user)

      assert !@group_pending.can_edit?(nil)
    end
  end
end
