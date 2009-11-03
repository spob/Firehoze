require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class TopicsControllerTest < ActionController::TestCase
  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
      @group = Factory.create(:group)
    end

    fast_context "on GET to :show" do
      setup { get :show, :id => Factory.create(:topic).id }

      should_assign_to :topic
      should_render_template 'show'
      should_respond_with :success
      should_not_set_the_flash
    end

    fast_context "on GET to :new" do
      setup { get :new, :group_id => @group }

      should_assign_to :topic
      should_respond_with :redirect
      should_set_the_flash_to /must be a member/
      should_redirect_to("Group show page") { group_url(@group) }
    end

    fast_context "on POST to :create" do
      setup do
        topic_attrs = Factory.attributes_for(:topic, :group => @group)
        post :create, :topic => topic_attrs, :group_id => @group
      end

      should_assign_to :group
      should_respond_with :redirect
      should_set_the_flash_to /must be a member/
      should_redirect_to("Group show page") { group_url(@group) }
    end

    fast_context "and a member of the group" do
      setup do
        @group_member = GroupMember.create!(:user => @user, :group => @group, :member_type => MEMBER)
      end

      context "on GET to :new" do
        setup { get :new, :group_id => @group }

        should_assign_to :topic
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "new"
      end

      fast_context "on POST to :create" do
        setup do
          topic_attrs = Factory.attributes_for(:topic, :group => @group)
          post :create, :topic => topic_attrs, :group_id => @group
        end

        should_assign_to :group
        should_assign_to :topic
        should_respond_with :redirect
        should_set_the_flash_to /recorded/
        should_redirect_to("Topic show page") { topic_url(assigns(:topic)) }
      end

      fast_context "on GET to :edit" do
        setup { get :edit, :id => Factory.create(:topic, :group => @group).id }

        should_respond_with :redirect
        should_set_the_flash_to /must be a moderator/
        should_redirect_to("Topic show page") { topic_url(assigns(:topic)) }
      end

      fast_context "as the group moderator" do
        setup do
          @group_member.update_attribute(:member_type, MODERATOR)
          assert @group.includes_member?(@user)
          assert @group.moderated_by?(@user)
        end

        fast_context "on GET to :edit" do
          setup { get :edit, :id => Factory.create(:topic, :group => @group).id }

          should_assign_to :topic
          should_not_set_the_flash
          should_render_template 'edit'
          should_respond_with :success
        end

        fast_context "as the owner" do
          setup do
            @group.update_attribute(:owner, @user)
            @group_member.update_attribute(:member_type, OWNER)
          end

          fast_context "on GET to :edit" do
            setup { get :edit, :id => Factory.create(:topic, :group => @group).id }

            should_assign_to :topic
            should_not_set_the_flash
            should_render_template 'edit'
            should_respond_with :success
          end
        end

        fast_context "with a topic defined" do
          setup { @topic = Factory.create(:topic) }
          fast_context "on PUT to :update" do
            setup { put :update, :id => @topic.id, :topic => @topic.attributes }

            should_set_the_flash_to /updated successfully/
            should_assign_to :topic
            should_respond_with :redirect
            should_redirect_to("Topic show page") { topic_url(assigns(:topic)) }
          end
        end
      end
    end
  end
end