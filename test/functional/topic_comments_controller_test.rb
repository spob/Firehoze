require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class TopicCommentsControllerTest < ActionController::TestCase
  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
      @topic = Factory.create(:topic)
    end

    fast_context "on GET to :new" do
      setup { get :new, :topic_id => @topic.id }

      should_assign_to :topic
      should_respond_with :redirect
      should_set_the_flash_to /must be a member/
      should_redirect_to("Group show page") { group_url(@topic.group) }
    end

    fast_context "and a member of the group" do
      setup do
        @group_member = GroupMember.create!(:user => @user, :group => @topic.group, :member_type => MEMBER)
      end

      context "on GET to :new" do
      setup { get :new, :topic_id => @topic.id }

        should_assign_to :topic
        should_assign_to :topic_comment
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "new"
      end
    end
  end
end
