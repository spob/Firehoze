require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class ReviewsControllerTest < ActionController::TestCase

  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "with a lesson defined" do
      setup do
        @lesson = Factory.create(:lesson)
        @user.credits.create!(:price => 0.99, :lesson => @lesson, :acquired_at => Time.now,
                              :line_item => Factory.create(:line_item))
        assert @user.owns_lesson?(@lesson)
      end

      fast_context "on POST to :create when not yet rated" do
        setup do
          @new_review_attrs = Factory.attributes_for(:review)
          post :create, :review => @new_review_attrs, :lesson_id => @lesson
        end

        should_assign_to :review
        should_respond_with :success
        should_render_template :new
      end


      fast_context "on GET to :new" do
        setup { get :new, :lesson_id => @lesson }

        should_assign_to :review
        should_assign_to :lesson
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "new"
      end

      fast_context "which the user has already rated" do
        setup do
          assert @lesson.rates.empty?
          @rate = @lesson.rates.create!(:user_id => @user.id)
          # I have no idea why the user id isn't set above RBS'
          @rate.update_attribute(:user_id, @user.id)
          assert !@lesson.rates.empty?
          assert_equal @user, @lesson.rates.first.user
        end

        fast_context "on GET to :index" do
          setup { get :index, :lesson_id => @lesson }

          should_assign_to :reviews
          should_assign_to :lesson
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "index"
        end

        fast_context "on POST to :create" do
          setup do
            @new_review_attrs = Factory.attributes_for(:review)
            post :create, :review => @new_review_attrs, :lesson_id => @lesson
          end

          should_assign_to :review
          should_respond_with :redirect
          should_set_the_flash_to :review_create_success
          should_redirect_to("lesson page") { lesson_url(@lesson, :anchor => "reviews") }
        end

        fast_context "on GET to :new when already reviewed" do
          setup do
            @lesson2 = Factory.create(:lesson)
            @credit = Factory.create(:credit, :user => @user, :lesson => @lesson2)
            @rate = @lesson2.rates.create!(:user_id => @user.id)
            # I have no idea why the user id isn't set above RBS'
            @rate.update_attribute(:user_id, @user.id)
            @review = @credit.lesson.reviews.create!(:body => 'hello',
                                                     :headline => 'headline',
                                                     :user => @user,
                                                     :lesson => @lesson2)
            assert @credit.lesson.reviewed_by?(@user)
            get :new, :lesson_id => @review.lesson
          end

          should_assign_to :review
          should_respond_with :redirect
          should_set_the_flash_to /You can only write a review for a lesson once/
          should_redirect_to("lesson page") { lesson_url(@credit.lesson, :anchor => "reviews") }
        end

        fast_context "on GET to :new when not owned" do
          setup do
            @lesson2 = Factory.create(:lesson)
            get :new, :lesson_id => @lesson2
            assert !@lesson2.owned_by?(@user)
          end

          should_assign_to :review
          should_respond_with :redirect
          should_set_the_flash_to /You can only review videos which you own/
          should_redirect_to("lesson page") { lesson_url(@lesson2, :anchor => "reviews") }
        end

#        fast_context "on GET to :show with a rejected review" do
#          setup do
#            @review = Factory.create(:review, :user => @user, :lesson => @lesson)
#            @review.update_attribute(:status, REVIEW_STATUS_REJECTED)
#            get :show, :id => @review
#          end
#
#          should_assign_to :review
#          should_respond_with :redirect
#          should_set_the_flash_to /not available/
#        end

        fast_context "with moderator access" do
          setup do
            @user.has_role 'moderator'
            assert @user.is_a_moderator?
          end

          fast_context "on GET to :edit" do
            setup do
              @review = Factory.create(:review, :user => @user, :lesson => @lesson)
              get :edit, :id => @review
            end

            should_assign_to :review
            should_respond_with :success
            should_not_set_the_flash
            should_render_template "edit"
          end

          fast_context "on PUT to :update" do
            setup do
              @review = Factory.create(:review, :user => @user, :lesson => @lesson)
              put :update, :id => @review, :lesson => @review.lesson
            end

            should_set_the_flash_to :review_update_success
            should_assign_to :review
            should_respond_with :redirect
            should_redirect_to("lesson page") { lesson_url(@lesson, :anchor => "reviews") }
          end

#          fast_context "on GET to :show" do
#            setup do
#              @review = Factory.create(:review, :user => @user, :lesson => @lesson)
#              get :show, :id => @review
#            end
#
#            should_assign_to :review
#            should_respond_with :success
#            should_not_set_the_flash
#            should_render_template "show"
#          end
        end

        fast_context "without moderator access" do
          setup do
            @user.has_no_role 'moderator'
          end

          fast_context "on GET to :edit" do
            setup do
              assert !@user.is_a_moderator?
              @review = Factory.create(:review, :user => @user, :lesson => @lesson)
              get :edit, :id => @review
            end

            # Since assigning to @review was moved to a before filter, @review now gets assigned
            #should_not_assign_to :review
            should_respond_with :redirect
            should_set_the_flash_to /Permission denied/
            should_redirect_to("Lessons index") { lessons_path }
          end

          fast_context "on PUT to :update" do
            setup do
              @review = Factory.create(:review, :user => @user, :lesson => @lesson)
              assert @user.owns_lesson?(@lesson)
              put :update, :id => @review, :lesson => @review.lesson
            end

            should_set_the_flash_to /Permission denied/
            # Since assigning to @review was moved to a before filter, @review now gets assigned
            #should_not_assign_to :review
            should_respond_with :redirect
            should_redirect_to("Lessons index") { lessons_path }
          end
        end
      end
    end
  end
end
