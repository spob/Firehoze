require 'test_helper'

class LessonCommentsControllerTest < ActionController::TestCase

  context "with a lesson defined" do
    setup { @lesson = Factory.create(:lesson)}

    context "and a lesson comment defined" do
      setup { @lesson_comment = Factory.create(:lesson_comment, :lesson => @lesson)}

      context "on GET to :index" do
        setup { get :index, :lesson_id => @lesson }

        should_assign_to :lesson_comments
        should_assign_to :lesson
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "index"

      end

      context "when logged on" do
        setup do
          activate_authlogic
          @user = Factory(:user)
          UserSession.create @user
        end

        context "on GET to :new" do
          setup { get :new, :lesson_id => @lesson }

          should_assign_to :lesson_comment
          should_assign_to :lesson
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "new"
        end

        context "on POST to :create" do
          setup do
            @new_lesson_comment_attrs = Factory.attributes_for(:lesson_comment)
            post :create, :lesson_comment => @new_lesson_comment_attrs, :lesson_id => @lesson
          end

          should_assign_to :lesson_comment
          should_respond_with :redirect
          should_set_the_flash_to :lesson_comment_create_success
          should_redirect_to("Lesson comments index page") { lesson_lesson_comments_url(@lesson) }
        end

        context "with moderator access" do
          setup do
            @user.has_role 'moderator'
            assert @user.is_moderator?
          end

          context "on GET to :edit" do
            setup { get :edit, :id => @lesson_comment }

            should_assign_to :lesson_comment
            should_respond_with :success
            should_not_set_the_flash
            should_render_template "edit"
          end

          context "on PUT to :update" do
            setup { put :update, :id => @lesson_comment, :lesson => @lesson_comment.lesson,
                        :lesson_comment => { :public => true } }

            should_set_the_flash_to :lesson_comment_update_success
            should_assign_to :lesson_comment
            should_respond_with :redirect
            should_redirect_to("lesson comments index page") { lesson_lesson_comments_url(@lesson_comment.lesson) }
          end
        end

        context "without moderator access" do
          setup { @user.has_no_role 'moderator' }

          context "on GET to :edit" do
            setup do
              assert !@user.is_moderator?
              assert !@lesson_comment.can_edit?(@user)
              get :edit, :id => @lesson_comment
            end

            should_respond_with :redirect
            should_set_the_flash_to /You do not have rights/
            should_redirect_to("Lesson Comments") { lesson_lesson_comments_path(@lesson) }
          end

          context "on PUT to :update" do
            setup do
              put :update, :id => @lesson_comment, :lesson => @lesson_comment.lesson,
                  :lesson_comment => { :public => true }
            end

            should_set_the_flash_to /You do not have rights/
            should_respond_with :redirect
            should_redirect_to("Lesson Comments") { lesson_lesson_comments_path(@lesson) }
          end
        end
      end
    end
  end
end
