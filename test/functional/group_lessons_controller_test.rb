require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class GroupLessonsControllerTest < ActionController::TestCase
  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "with a group defined and a lesson defined" do
      setup do
        @group = Factory.create(:group, :owner => @user)
        @lesson = Factory.create(:lesson)
        @lesson.update_attribute(:instructor, @user)
      end

      fast_context "on POST to :create" do
        setup { post :create, :id => @group.id, :lesson_id => @lesson }

        should_set_the_flash_to /added/
        should_assign_to :group
        should_assign_to :lesson
        should_respond_with :redirect
        should_redirect_to("Lesson page") { lesson_url(@lesson.id, :anchor => "groups") }
        should "add lesson to group" do
          assert @lesson.belongs_to_group?(@group)
        end
      end

      fast_context "on DELETE to :destroy" do
        setup { delete :destroy, :id => @group.id, :lesson_id => @lesson }

        should_set_the_flash_to /Lesson is not a member/
        should_assign_to :group
        should_assign_to :lesson
        should_respond_with :redirect
        should_redirect_to("Lesson page") { lesson_url(@lesson.id, :anchor => "groups") }
        should "add lesson to group" do
          assert !@lesson.belongs_to_group?(@group)
        end
      end

      fast_context "lesson belongs to the group" do
        setup do
          @group_lesson = GroupLesson.create!(:user => @user, :lesson => @lesson, :group => @group)
        end

        fast_context "on POST to :create" do
          setup { post :create, :id => @group.id, :lesson_id => @lesson }

          should_set_the_flash_to /Lesson is already associated/
          should_assign_to :group
          should_assign_to :lesson
          should_respond_with :redirect
          should_redirect_to("Lesson page") { lesson_url(@lesson.id, :anchor => "groups") }
          should "add lesson to group" do
            assert @lesson.belongs_to_group?(@group)
          end
        end

        fast_context "on DELETE to :destroy" do
          setup { delete :destroy, :id => @group.id, :lesson_id => @lesson }

          should_set_the_flash_to /Lesson removed/
          should_assign_to :group
          should_assign_to :lesson
          should_respond_with :redirect
          should_redirect_to("Lesson page") { lesson_url(@lesson.id, :anchor => "groups") }
          should "add lesson to group" do
            assert !@lesson.belongs_to_group?(@group)
          end
        end

        fast_context "lesson belongs to the group" do
          setup do
            @group_lesson.update_attribute(:active, false)
          end

          fast_context "on POST to :create" do
            setup { post :create, :id => @group.id, :lesson_id => @lesson }

            should_set_the_flash_to /added/
            should_assign_to :group
            should_assign_to :lesson
            should_respond_with :redirect
            should_redirect_to("Lesson page") { lesson_url(@lesson.id, :anchor => "groups") }
            should "add lesson to group" do
              assert @lesson.belongs_to_group?(@group)
            end
          end

          fast_context "on DELETE to :destroy" do
            setup { delete :destroy, :id => @group.id, :lesson_id => @lesson }

            should_set_the_flash_to /Lesson is not a member/
            should_assign_to :group
            should_assign_to :lesson
            should_respond_with :redirect
            should_redirect_to("Lesson page") { lesson_url(@lesson.id, :anchor => "groups") }
            should "add lesson to group" do
              assert !@lesson.belongs_to_group?(@group)
            end
          end
        end
      end
    end
  end
end