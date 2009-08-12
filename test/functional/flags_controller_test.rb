require 'test_helper'

class FlagsControllerTest < ActionController::TestCase
  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "given an existing lesson" do
      setup do
        @lesson = Factory.create(:lesson)
      end

      context "on GET to :new" do
        setup { get :new, :flagger_type => 'Lesson', :flagger_id => @lesson }

        should_assign_to :flag
        should_assign_to :flagger
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "new"
      end

      context "on POST to :create" do
        setup do
          assert Flag.all.empty?
          @new_flag_attr = Factory.attributes_for(:flag, :flaggable_id => @lesson.id)
          post :create, :flag => @new_flag_attr, :flagger_type => 'Lesson', :flagger_id => @lesson
        end

        should_assign_to :flagger
        should_respond_with :redirect
        should_set_the_flash_to /Thank you for bringing this to our attention/
        should "create a flag" do
          assert_equal 1, Flag.all.size
        end
        #should_redirect_to("Show lessons page") { '"url_for(:controller => 'Lessons', :action => 'show', :id => id)"' }

        context "and try to flag a second time" do
          setup do
            post :create, :flag => @new_flag_attr, :flagger_type => 'Lesson', :flagger_id => @lesson
          end

          should_assign_to :flagger
          should_respond_with :success
          should_render_template :new
        end
      end
    end

    context "given an existing review" do
      setup do
        @credit = Factory.create(:credit, :user => @user)
        @review = @credit.lesson.reviews.create!(:body => 'hello',
                                                 :headline => 'headline',
                                                 :user => @user)
        assert @credit.lesson.reviewed_by?(@user)
      end

      context "on GET to :new" do
        setup { get :new, :flagger_type => 'Review', :flagger_id => @review }

        should_assign_to :flag
        should_assign_to :flagger
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "new"
      end

      context "on POST to :create" do
        setup do
          assert Flag.all.empty?
          @new_flag_attr = Factory.attributes_for(:flag, :flaggable_id => @review.id)
          post :create, :flag => @new_flag_attr, :flagger_type => 'Review', :flagger_id => @review
        end

        should_assign_to :flagger
        should_respond_with :redirect
        should_set_the_flash_to /Thank you for bringing this to our attention/
        should "create a flag" do
          assert_equal 1, Flag.all.size
        end
        #should_redirect_to("Show lessons page") { '"url_for(:controller => 'Lessons', :action => 'show', :id => id)"' }

        context "and try to flag a second time" do
          setup do
            post :create, :flag => @new_flag_attr, :flagger_type => 'Review', :flagger_id => @review
          end

          should_assign_to :flagger
          should_respond_with :success
          should_render_template :new
        end
      end
    end

    context "given an existing lesson comment" do
      setup do
        @lesson_comment = Factory.create(:lesson_comment)
      end

      context "on GET to :new" do
        setup { get :new, :flagger_type => 'LessonComment', :flagger_id => @lesson_comment }

        should_assign_to :flag
        should_assign_to :flagger
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "new"
      end

      context "on POST to :create" do
        setup do
          assert Flag.all.empty?
          @new_flag_attr = Factory.attributes_for(:flag, :flaggable_id => @lesson_comment.id)
          post :create, :flag => @new_flag_attr, :flagger_type => 'LessonComment', :flagger_id => @lesson_comment
        end

        should_assign_to :flagger
        should_respond_with :redirect
        should_set_the_flash_to /Thank you for bringing this to our attention/
        should "create a flag" do
          assert_equal 1, Flag.all.size
        end
        #should_redirect_to("Show lessons page") { '"url_for(:controller => 'Lessons', :action => 'show', :id => id)"' }

        context "and try to flag a second time" do
          setup do
            post :create, :flag => @new_flag_attr, :flagger_type => 'LessonComment', :flagger_id => @lesson_comment
          end

          should_assign_to :flagger
          should_respond_with :success
          should_render_template :new
        end
      end
    end
  end
end
