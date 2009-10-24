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
        should_redirect_to("Group index page") { groups_url }
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
          should_redirect_to("Group index page") { groups_url }
          should "removed user from group" do
            assert !@group.includes_member?(@user)
          end
        end
      end
    end
  end
end