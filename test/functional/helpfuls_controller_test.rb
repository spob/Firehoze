require 'test_helper'

class HelpfulsControllerTest < ActionController::TestCase

  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "with a review" do
      setup do
        @lesson = Factory.create(:lesson)
        @user.credits.create(:price => 0.99, :lesson => @lesson)
        @review = Factory.create(:review, :user => @user, :lesson => @lesson)
      end

      context "on POST to :create" do
        setup do
          post :create, :review_id => @review
        end

        should_assign_to :review
        should_respond_with :redirect
        should_set_the_flash_to I18n.t('helpful.create_success')
        should_redirect_to("Review page") { lesson_reviews_url(@review.lesson) }
      end

      context "as the author" do
        setup { UserSession.create(@review.lesson.instructor) }
        context "on POST to :create" do
          setup { post :create, :review_id => @review }

          should_assign_to :review
          should_respond_with :redirect
          should_set_the_flash_to I18n.t('helpful.cant_helpful_as_instructor')
          should_redirect_to("Review page") { lesson_reviews_url(@review.lesson) }
        end
      end
    end
  end
end
