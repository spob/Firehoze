require 'test_helper'

class LessonsControllerTest < ActionController::TestCase

  context "while not logged in" do

    context "on GET to :index" do
      setup { get :index }

      should_assign_to :lessons
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "index"
    end

    context "on GET to :show" do
      setup { get :show, :id => Factory(:lesson).id }

      should_assign_to :lesson
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "show"
    end

    context "on GET to :new" do
      setup { get :new }

      should_not_assign_to :lesson
      should_respond_with :redirect
      should_set_the_flash_to /You must be logged in/
      should_redirect_to("login page") { new_user_session_url }
    end
  end

  context "when logged in" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "on GET to :index" do
      setup { get :index }

      should_assign_to :lessons
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "index"
    end

    context "on GET to :new" do
      setup { get :new }

      should_assign_to :lesson
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    context "on POST to :create" do
      setup do
        post :create, :lesson => Factory.attributes_for(:lesson)
      end

      should_assign_to :lesson
      should_respond_with :redirect
      should_set_the_flash_to "Lesson created"
      should_redirect_to("lessons index page") { lesson_url(assigns(:lesson)) }
    end

    context "with at least one existing lesson" do

      setup do
        Factory.create(:user)
        @lesson = Factory.create(:lesson)
        @lesson.author = @user
        @lesson.save!
      end

      context "on GET to :edit" do
        setup { get :edit, :id => @lesson }
        should_assign_to :lesson
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "edit"
      end

      context "on PUT to :update" do
        setup { put :update, :id => @lesson.id, :lesson => Factory.attributes_for(:lesson) }

        should_set_the_flash_to "Lesson updated!"
        should_assign_to :lesson
        should_respond_with :redirect
        should_redirect_to("lesson page") { lesson_path(@lesson) }
      end

      context "which was authored by a different user" do
        setup do
          @lesson.author = Factory.create(:user, :email => 'some@other.com')
          @lesson.save!
        end

        context "on GET to :edit" do
          setup { get :edit, :id => @lesson }
          should_assign_to :lesson
          should_redirect_to("lesson page") { lesson_path(@lesson) }
          should_set_the_flash_to /do not have access/
        end

        context "on PUT to :update" do
          setup { put :update, :id => @lesson.id, :lesson => Factory.attributes_for(:lesson) }
          should_assign_to :lesson
          should_redirect_to("lesson page") { lesson_path(@lesson) }
          should_set_the_flash_to /do not have access/
        end
      end
    end
  end
end