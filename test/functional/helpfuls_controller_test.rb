require 'test_helper'

class HelpfulsControllerTest < ActionController::TestCase

  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "with a review" do
      setup { @review = Factory.create(:review) }
      
      context "on POST to :create" do
        setup do
          post :create, :review_id => @review, :user_id => @user
        end

        should_assign_to :review
        should_respond_with :redirect
        should_set_the_flash_to I18n.t('helpful.create_success')
        should_redirect_to("Review page") { lesson_reviews_url(@review.lesson) }
      end
    end
  end
end
