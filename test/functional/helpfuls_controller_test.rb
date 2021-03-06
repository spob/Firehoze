require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class HelpfulsControllerTest < ActionController::TestCase

  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "with a review" do
      setup do
        @lesson = Factory.create(:lesson)
        assert @lesson.rates.empty?
        @user.credits.create!(:price => 0.99, :lesson => @lesson)
        @rate = @lesson.rates.create!(:user_id => @user.id)
        # I have no idea why the user id isn't set above RBS'
        @rate.update_attribute(:user_id, @user.id)
        assert !@lesson.rates.empty?
        assert_equal @lesson, @lesson.rates.first.rateable
        assert_equal @user, @lesson.rates.first.user
        assert_equal @lesson.id, @lesson.rates.first.rateable.id
        assert !@user.rates.lesson_rates.by_rateable_id(@lesson).empty?
        @review = Factory.create(:review, :user => @user, :lesson => @lesson)
      end

      fast_context "on POST to :create" do
        setup do
          post :create, :review_id => @review
        end

        should_assign_to :review
        should_respond_with :redirect
        should_set_the_flash_to I18n.t('helpful.create_success')
        should_redirect_to("Show lessons page") { lesson_url(@review.lesson, :anchor => 'reviews') }
      end

      fast_context "as the author" do
        setup { UserSession.create(@review.lesson.instructor) }
        fast_context "on POST to :create" do
          setup { post :create, :review_id => @review }

          should_assign_to :review
          should_respond_with :redirect
          should_set_the_flash_to I18n.t('helpful.cant_helpful_as_instructor')
          should_redirect_to("Show lessons page") { lesson_url(@review.lesson, :anchor => 'reviews') }
        end
      end
    end
  end
end
