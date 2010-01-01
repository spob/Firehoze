require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class LessonCommentsControllerTest < ActionController::TestCase


  def self.test_create_success
    should_assign_to :lesson_comment
    should_respond_with :redirect
    should_set_the_flash_to :lesson_comment_create_success
    should_redirect_to("Lesson comments index page") { lesson_url(@lesson, :anchor => :lesson_comment) }
  end

  def self.test_new_success
    should_assign_to :lesson_comment
    should_assign_to :lesson
    should_respond_with :success
    should_not_set_the_flash
    should_render_template "new"
  end

  fast_context "with a lesson defined" do
    setup { @lesson = Factory.create(:lesson)}

    fast_context "and a lesson comment defined" do
      setup { @lesson_comment = Factory.create(:lesson_comment, :lesson => @lesson)}

      fast_context "on GET to :index" do
        setup { get :index, :lesson_id => @lesson }

        should_assign_to :lesson_comments
        should_assign_to :lesson
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "index"

      end

      fast_context "when logged on" do
        setup do
          activate_authlogic
          @user = Factory(:user)
          UserSession.create @user
        end

        fast_context "on GET to :new" do
          setup { get :new, :lesson_id => @lesson }

          should_not_assign_to :lesson_comment
          should_assign_to :lesson
          should_respond_with :redirect
          should_set_the_flash_to /You must first purchase/
          should_redirect_to("Lesson show page") { lesson_url(@lesson, :anchor => :lesson_comment) }
        end

        fast_context "when having instructed the lesson" do
          setup do
            @lesson.update_attribute(:instructor, @user)
            assert @lesson.instructed_by?(@user)
          end

          fast_context "on GET to :new" do
            setup { get :new, :lesson_id => @lesson }

            test_new_success
          end

          fast_context "on POST to :create" do
            setup do
              @new_lesson_comment_attrs = Factory.attributes_for(:lesson_comment)
              post :create, :lesson_comment => @new_lesson_comment_attrs, :lesson_id => @lesson
            end

            test_create_success
          end
        end

        fast_context "when a moderator lesson" do
          setup do
            @user.is_moderator
          end

          fast_context "on GET to :new" do
            setup { get :new, :lesson_id => @lesson }

            test_new_success
          end

          fast_context "on POST to :create" do
            setup do
              @new_lesson_comment_attrs = Factory.attributes_for(:lesson_comment)
              post :create, :lesson_comment => @new_lesson_comment_attrs, :lesson_id => @lesson
            end

            test_create_success
          end
        end

        fast_context "when an admin" do
          setup do
            @user.is_admin
          end

          fast_context "on GET to :new" do
            setup { get :new, :lesson_id => @lesson }

            test_new_success
          end

          fast_context "on POST to :create" do
            setup do
              @new_lesson_comment_attrs = Factory.attributes_for(:lesson_comment)
              post :create, :lesson_comment => @new_lesson_comment_attrs, :lesson_id => @lesson
            end

            test_create_success
          end
        end

        fast_context "when owns the lessons" do
          setup do
          @user.credits.create!(:price => 0.99, :lesson => @lesson)
          assert @user.owns_lesson?(@lesson)
          end

          fast_context "on GET to :new" do
            setup { get :new, :lesson_id => @lesson }

            test_new_success
          end

          fast_context "on POST to :create" do
            setup do
              @new_lesson_comment_attrs = Factory.attributes_for(:lesson_comment)
              post :create, :lesson_comment => @new_lesson_comment_attrs, :lesson_id => @lesson
            end

            test_create_success
          end
        end

        fast_context "on POST to :create" do
          setup do
            @new_lesson_comment_attrs = Factory.attributes_for(:lesson_comment)
            post :create, :lesson_comment => @new_lesson_comment_attrs, :lesson_id => @lesson
          end

          should_not_assign_to :lesson_comment
          should_respond_with :redirect
          should_set_the_flash_to /You must first purchase/
          should_redirect_to("Lesson show page") { lesson_url(@lesson, :anchor => :lesson_comment) }
        end

        fast_context "with moderator access" do
          setup do
            @user.has_role 'moderator'
            assert @user.is_moderator?
          end

          fast_context "on GET to :edit" do
            setup { get :edit, :id => @lesson_comment }

            should_assign_to :lesson_comment
            should_respond_with :success
            should_not_set_the_flash
            should_render_template "edit"
          end

          fast_context "on PUT to :update" do
            setup { put :update, :id => @lesson_comment, :lesson => @lesson_comment.lesson,
                        :lesson_comment => { :public => true } }

            should_set_the_flash_to :lesson_comment_update_success
            should_assign_to :lesson_comment
            should_respond_with :redirect
            should_redirect_to("lesson comments index page") { lesson_url(@lesson, :anchor => :lesson_comment) }
          end
        end

        fast_context "without moderator access" do
          setup { @user.has_no_role 'moderator' }

          fast_context "on GET to :edit" do
            setup do
              assert !@user.is_moderator?
              assert !@lesson_comment.can_edit?(@user)
              get :edit, :id => @lesson_comment
            end

            should_respond_with :redirect
            should_set_the_flash_to /You do not have rights/
            should_redirect_to("Lesson Comments") { lesson_url(@lesson, :anchor => :lesson_comment) }
          end

          fast_context "on PUT to :update" do
            setup do
              put :update, :id => @lesson_comment, :lesson => @lesson_comment.lesson,
                  :lesson_comment => { :public => true }
            end

            should_set_the_flash_to /You do not have rights/
            should_respond_with :redirect
            should_redirect_to("Lesson Comments") { lesson_url(@lesson, :anchor => :lesson_comment) }
          end
        end
      end
    end
  end
end
