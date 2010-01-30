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

    fast_context "with a topic comment defined" do
      setup { @topic_comment = Factory.create(:topic_comment) }

      fast_context "with moderator access" do
        setup do
          @user.has_role 'moderator'
          assert @user.is_a_moderator?
        end

        fast_context "on GET to :edit" do
          setup { get :edit, :id => @topic_comment }

          should_assign_to :topic_comment
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "edit"
        end

        fast_context "on PUT to :update" do
          setup { put :update, :id => @topic_comment, :topic => @topic_comment.topic,
                      :topic_comment => { :public => true } }

          should_set_the_flash_to :topic_comment_update_success
          should_assign_to :topic_comment
          should_respond_with :redirect
          should_redirect_to("Topic Show") { topic_path(@topic_comment.topic) }
        end
      end

      fast_context "as a group moderator" do
        setup do
        @group_member = GroupMember.create!(:user => @user, :group => @topic_comment.topic.group, :member_type => MODERATOR)
        end

        fast_context "on GET to :edit" do
          setup { get :edit, :id => @topic_comment }

          should_assign_to :topic_comment
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "edit"
        end

        fast_context "on PUT to :update" do
          setup { put :update, :id => @topic_comment, :topic => @topic_comment.topic,
                      :topic_comment => { :public => true } }

          should_set_the_flash_to :topic_comment_update_success
          should_assign_to :topic_comment
          should_respond_with :redirect
          should_redirect_to("Topic Show") { topic_path(@topic_comment.topic) }
        end
      end

      fast_context "without moderator access" do
        setup { @user.has_no_role 'moderator' }

        fast_context "on GET to :edit" do
          setup do
            assert !@user.is_a_moderator?
            assert !@topic_comment.can_edit?(@user)
            get :edit, :id => @topic_comment
          end

          should_respond_with :redirect
          should_set_the_flash_to /You do not have rights/
          should_redirect_to("Topic Show") { topic_path(@topic_comment.topic) }
        end

        fast_context "on PUT to :update" do
          setup do
            put :update, :id => @topic_comment, :topic => @topic_comment.topic,
                :topic_comment => { :public => true }
          end

          should_set_the_flash_to /You do not have rights/
          should_respond_with :redirect
          should_redirect_to("Topic Show") { topic_path(@topic_comment.topic) }
        end
      end
    end
  end
end
