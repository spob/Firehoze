require 'test_helper'

class ReviewsControllerTest < ActionController::TestCase

  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "with a lesson defined" do
      setup do
        @lesson = Factory.create(:lesson)
        @user.credits.create!(:price => 0.99, :lesson => @lesson, :acquired_at => Time.now,
                              :line_item => Factory.create(:line_item))
        assert @user.owns_lesson?(@lesson)
      end

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
        should_set_the_flash_to :review_create_success
        should_redirect_to("Reviews index page") { lesson_reviews_url(@lesson) }
      end

      context "on GET to :new when already reviewed" do
        setup do
          @credit = Factory.create(:credit, :user => @user)
          @review = @credit.lesson.reviews.create!(:body => 'hello',
                                                   :headline => 'headline',
                                                   :user => @user)
          assert @credit.lesson.reviewed_by?(@user)
          get :new, :lesson_id => @review.lesson
        end

        should_assign_to :review
        should_respond_with :redirect
        should_set_the_flash_to /You can only write a review for a lesson once/
        should_redirect_to("Reviews index page") { lesson_reviews_url(@credit.lesson) }
      end

      context "on GET to :new when not owned" do
        setup do
          @lesson2 = Factory.create(:lesson)
          get :new, :lesson_id => @lesson2
          assert !@lesson2.owned_by?(@user)  
        end

        should_assign_to :review
        should_respond_with :redirect
        should_set_the_flash_to /You can only review videos which you have viewed/
        should_redirect_to("Reviews index page") { lesson_reviews_url(@lesson2) }
      end

      context "with moderator access" do
        setup do
          @user.has_role 'moderator'
          assert @user.is_moderator?
        end

        context "on GET to :edit" do
          setup do
            @review = Factory.create(:review, :user => @user, :lesson => @lesson)
            get :edit, :id => @review
          end

          should_assign_to :review
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "edit"
        end

        context "on PUT to :update" do
          setup do
            @review = Factory.create(:review, :user => @user, :lesson => @lesson)
            put :update, :id => @review, :lesson => @review.lesson
          end

          should_set_the_flash_to :review_update_success
          should_assign_to :review
          should_respond_with :redirect
          should_redirect_to("Reviews index page") { lesson_reviews_url(@review.lesson) }
        end
      end

      context "without moderator access" do
        setup do
          @user.has_no_role 'moderator'
        end

        context "on GET to :edit" do
          setup do
            assert !@user.is_moderator?
            @review = Factory.create(:review, :user => @user, :lesson => @lesson)
            get :edit, :id => @review
          end

          # Since assigning to @review was moved to a before filter, @review now gets assigned
          #should_not_assign_to :review
          should_respond_with :redirect
          should_set_the_flash_to /Permission denied/
          should_redirect_to("home") { home_path }
        end

        context "on PUT to :update" do
          setup do
            @review = Factory.create(:review, :user => @user, :lesson => @lesson)
            assert @user.owns_lesson?(@lesson)
            put :update, :id => @review, :lesson => @review.lesson
          end

          should_set_the_flash_to /Permission denied/
          # Since assigning to @review was moved to a before filter, @review now gets assigned
          #should_not_assign_to :review
          should_respond_with :redirect
          should_redirect_to("home") { home_path }
        end
      end
    end
  end
end
