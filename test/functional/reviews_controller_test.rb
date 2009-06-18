require 'test_helper'

class ReviewsControllerTest < ActionController::TestCase

  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "with a lesson defined" do
      setup { @lesson = Factory.create(:lesson) }

      context "on GET to :index" do
        setup { get :index, :lesson_id => @lesson }

        should_assign_to :reviews
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "index"
      end

      context "on GET to :new" do
        setup { get :new, :lesson_id => @lesson }

        should_assign_to :review
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "new"
      end

      context "on POST to :create" do
        setup do
          @new_review_attrs = Factory.attributes_for(:review)
          post :create, :review => @new_review_attrs, :lesson_id => @lesson
        end

        should_assign_to :review
        should_respond_with :redirect
        should_set_the_flash_to :review_create_sucess
        should_redirect_to("Reviews index page") { lesson_reviews_url(@lesson) }
      end

      context "with moderator access" do
        setup do
          @user.has_role 'moderator'
        end
        context "on GET to :edit" do
          setup { get :edit, :id => Factory.create(:review) }

          should_assign_to :review
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "edit"
        end

        context "on PUT to :update" do
          setup do
            @review = Factory.create(:review)
            put :update, :id => @review, :lesson => @review.lesson
          end

          should_set_the_flash_to :review_update_sucess
          should_assign_to :review
          should_respond_with :redirect
          should_redirect_to("Reviews index page") { lesson_reviews_url(@review.lesson) }
        end
      end

      context "without moderator access" do
        context "on GET to :edit" do
          setup { get :edit, :id => Factory.create(:review) }

          should_not_assign_to :review
          should_respond_with :redirect
          should_set_the_flash_to /Permission denied/
          should_redirect_to("home") { home_path }
        end

        context "on PUT to :update" do
          setup do
            @review = Factory.create(:review)
            put :update, :id => @review, :lesson => @review.lesson
          end

          should_set_the_flash_to /Permission denied/
          should_not_assign_to :review
          should_respond_with :redirect
          should_redirect_to("home") { home_path }
        end
      end
    end
  end
end
