require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class GroupInvitationsControllerTest < ActionController::TestCase

  fast_context "with a group defined" do
    setup { @group = Factory.create(:group) }

    fast_context "when logged on" do
      setup do
        activate_authlogic
        @user = Factory(:user)
        UserSession.create @user
      end

      fast_context "on GET to :new" do
        setup { get :new, :id => @group.id }

        should_set_the_flash_to /You can only extend invitations to private groups/
        should_redirect_to("show group page") { group_path(@group) }
      end

      fast_context "with the group being private" do
        setup do
          @group.private = true
          @group.save!
        end

        fast_context "on GET to :new" do
          setup { get :new, :id => @group.id }

          should_set_the_flash_to /You must be either an owner or moderator/
          should_redirect_to("show group page") { group_path(@group) }
        end

        fast_context "and the current user being a moderator for that group" do
          setup do
            @group_member = GroupMember.create!(:user => @user, :group => @group, :member_type => MODERATOR)
            assert @group.moderated_by?(@user)
          end

          fast_context "on GET to :new" do
            setup { get :new, :id => @group.id }

            should_assign_to :group
            should "set group variable" do
              assert_equal @group, assigns(:group)
            end
            should_not_set_the_flash
            should_render_template 'new'
          end

          fast_context "on POST to :create via login" do
            setup do
              @to_user = Factory(:user)
              post :create, :id => @group.id, :group_invitation => { :to_user => @to_user.login }
            end
            should_set_the_flash_to /You have sent an invitation/
            should_assign_to :group
            should_assign_to :group_invitation
            should_assign_to :group_member
            should "set to pending" do
              assert_equal PENDING, assigns(:group_member).member_type
            end
          end

          fast_context "on POST to :create via email" do
            setup do
              @to_user = Factory(:user)
              post :create, :id => @group.id, :group_invitation => { :to_user_email => @to_user.email }
            end
            should_set_the_flash_to /You have sent an invitation/
            should_assign_to :group
            should_assign_to :group_invitation
            should_assign_to :group_member
            should "set to pending" do
              assert_equal PENDING, assigns(:group_member).member_type
            end


            fast_context "and resend an invitation on POST to :create via email" do
              setup do
                @to_user = Factory(:user)
                post :create, :id => @group.id, :group_invitation => { :to_user_email => @to_user.email }
              end
              should_set_the_flash_to /You have sent an invitation/
              should_assign_to :group
              should_assign_to :group_invitation
              should_assign_to :group_member
              should "set to pending" do
                assert_equal PENDING, assigns(:group_member).member_type
              end
            end
          end
        end
      end
    end
  end
end