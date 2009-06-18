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
          post :create, :review => Factory.attributes_for(:review), :lesson_id => @lesson
        end 

        should_assign_to :review
        should_respond_with :redirect
        should_set_the_flash_to :review_create_sucess
        should_redirect_to("Reviews index page") { lesson_reviews_url(@lesson) }
      end
    end
  end
end
