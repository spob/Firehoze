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

    context "on GET to :new" do
      setup { get :new, :group_id => @group }

      should_assign_to :topic
      should_respond_with :redirect
      should_set_the_flash_to /must be a member/
      should_redirect_to("Group show page") { group_url(@group) }
    end

    context "on POST to :create" do
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

      context "on POST to :create" do
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
    end
  end
end