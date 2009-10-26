require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class GroupMembersControllerTest < ActionController::TestCase
  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "with a group defined" do
      setup { @group = Factory.create(:group) }

      fast_context "on POST to :create" do
        setup do
          assert !@group.includes_member?(@user)
          post :create, :id => @group
        end

        should_set_the_flash_to /joined/
        should_assign_to :group
        should_respond_with :redirect
        should_redirect_to("Group page") { group_url(@group) }
        should "add user to group" do
          assert @group.includes_member?(@user)
        end
      end

      fast_context "and the user as a member" do
        setup { @group_member = GroupMember.create!(:user => @user, :group => @group, :member_type => MEMBER) }

        fast_context "on DELETE to :destroy" do
          setup do
            assert @group.includes_member?(@user)
            delete :destroy, :id => @group
          end

          should_set_the_flash_to /left/
          should_assign_to :group
          should_respond_with :redirect
          should_redirect_to("Group page") { group_url(@group) }
          should "removed user from group" do
            assert !@group.includes_member?(@user)
          end
        end
      end

      fast_context "and the user as a pending member" do
        setup { @group_member = GroupMember.create!(:user => @user, :group => @group, :member_type => PENDING) }

        fast_context "on POST to :new_create" do
          setup do
            post :new_create, :id => @group_member
          end

          should_set_the_flash_to /Welcome/
          should_assign_to :group_member
          should_respond_with :redirect
          should_redirect_to("Group page") { group_url(@group) }
          should "added user to group" do
            assert MEMBER, assigns(:group_member).member_type
          end
        end
      end

      fast_context "and a wrong user as a pending member" do
        setup { @group_member = GroupMember.create!(:user => Factory.create(:user), :group => @group, :member_type => PENDING) }

        fast_context "on POST to :new_create" do
          setup do
            post :new_create, :id => @group_member
          end

          should_set_the_flash_to /You must be logged in as .* to view this invitation/
          should_assign_to :group_member
          should_respond_with :redirect
          should_redirect_to("Home Page") { home_url }
          should "did not add user to group" do
            assert PENDING, assigns(:group_member).member_type
          end
        end
      end

      fast_context "and the user as a owner and another user as a member" do
        setup do
          @group.update_attribute(:owner, @user)
          @group_owner = GroupMember.create!(:user => @user, :group => @group, :member_type => OWNER)
          @group_moderator = GroupMember.create!(:user => Factory.create(:user), :group => @group, :member_type => MODERATOR)
          @group_member = GroupMember.create!(:user => Factory.create(:user), :group => @group, :member_type => MEMBER)
          @group_pending = GroupMember.create!(:user => Factory.create(:user), :group => @group, :member_type => PENDING)
        end

        fast_context "on DELETE to :remove" do
          setup do
            @removed_user = @group_member.user
            delete :remove, :id => @group_member
          end

          should_set_the_flash_to /You have removed/
          should_assign_to :group_member
          should_assign_to :group
          should_assign_to :user
          should_respond_with :redirect
          should_redirect_to("Group page") { group_url(@group) }
          should "removed user from group" do
            assert !@group.includes_member?(@removed_user)
          end
        end

        fast_context "on POST to :promote" do
          setup do
            assert_equal MEMBER, @group_member.member_type
            post :promote, :id => @group_member
          end

          should_set_the_flash_to /You have promoted/
          should_assign_to :group_member
          should_respond_with :redirect
          should_redirect_to("Group page") { group_url(@group) }
          should "promote user to moderator" do
            @group_member = GroupMember.find(@group_member)
            assert_equal MODERATOR, @group_member.member_type
          end
        end

        fast_context "on POST to :demote" do
          setup do
            assert_equal MODERATOR, @group_moderator.member_type
            post :demote, :id => @group_moderator
          end

          should_set_the_flash_to /is no longer a moderator/
          should_assign_to :group_member
          should_respond_with :redirect
          should_redirect_to("Group page") { group_url(@group) }
          should "demote user to member" do
            @group_moderator = GroupMember.find(@group_moderator)
            assert_equal MEMBER, @group_moderator.member_type
          end
        end
      end
    end
  end
end