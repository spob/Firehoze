require 'test_helper'

class FlagsControllerTest < ActionController::TestCase
  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "without moderator access" do
      context "on GET to :index" do
        setup { get :index }

        should_respond_with :redirect
        should_set_the_flash_to /Permission denied/
        should_redirect_to("home page") { lessons_path }
      end
    end

    context "with moderator access" do
      setup { @user.has_role 'moderator' }

      context "with several existing flags" do
        setup do
          @lesson_comment = Factory.create(:lesson_comment)
          @flag1 = @lesson_comment.flags.create!(:status => FLAG_STATUS_PENDING, :reason_type => "Smut", :comments => "Some comments",
                                                 :user => Factory.create(:user))
          @flag2 = @lesson_comment.flags.create!(:status => FLAG_STATUS_PENDING, :reason_type => "Smut", :comments => "Some comments",
                                                 :user => Factory.create(:user))
          @flag3 = Factory.create(:lesson_comment).flags.create!(:status => FLAG_STATUS_PENDING, :reason_type => "Smut", :comments => "Some comments",
                                                                 :user => Factory.create(:user))
          assert !@flag1.nil?
          assert !@flag2.nil?
          assert !@flag3.nil?
        end

        context "on PUT to :update to upon the flag with status pending" do
          setup do
            put :update, :id => @flag1, :flag => { :response => "Some reason", :status => FLAG_STATUS_PENDING}
            @flag1 = Flag.find(@flag1.id)
            @flag2 = Flag.find(@flag2.id)
            @flag3 = Flag.find(@flag3.id)
          end

          should_set_the_flash_to /success/
          should_assign_to :flag
          should_respond_with :redirect
          should_redirect_to("Flag show page") { flag_url(@flag1) }
          should "update the flag" do
            assert_equal "Some reason", @flag1.response
            assert_equal FLAG_STATUS_PENDING, @flag1.status
            assert "Some reason" != @flag2.response
            assert_equal FLAG_STATUS_PENDING, @flag2.status
            assert "Some reason" != @flag3.response
            assert_equal FLAG_STATUS_PENDING, @flag3.status

            assert COMMENT_STATUS_ACTIVE, @flag1.flaggable.status
            assert COMMENT_STATUS_ACTIVE, @flag2.flaggable.status
            assert COMMENT_STATUS_ACTIVE, @flag3.flaggable.status
          end
        end

        context "on PUT to :update to upon the flag with status rejected" do
          setup do
            put :update, :id => @flag1, :flag => { :response => "Some reason", :status => FLAG_STATUS_REJECTED }
            @flag1 = Flag.find(@flag1.id)
            @flag2 = Flag.find(@flag2.id)
            @flag3 = Flag.find(@flag3.id)
          end

          should_set_the_flash_to /success/
          should_assign_to :flag
          should_respond_with :redirect
          should_redirect_to("Flags index page") { flags_url }
          should "update the flag" do
            assert_equal "Some reason", @flag1.response
            assert_equal FLAG_STATUS_REJECTED, @flag1.status
            assert "Some reason" != @flag2.response
            assert_equal FLAG_STATUS_PENDING, @flag2.status
            assert "Some reason" != @flag3.response
            assert_equal FLAG_STATUS_PENDING, @flag3.status

            assert COMMENT_STATUS_ACTIVE, @flag1.flaggable.status
            assert COMMENT_STATUS_ACTIVE, @flag2.flaggable.status
            assert COMMENT_STATUS_ACTIVE, @flag3.flaggable.status
          end
        end

        context "on PUT to :update to upon the flag with status resolved manually" do
          setup do
            put :update, :id => @flag1, :flag => { :response => "Some reason", :status => FLAG_STATUS_RESOLVED_MANUALLY }
            @flag1 = Flag.find(@flag1.id)
            @flag2 = Flag.find(@flag2.id)
            @flag3 = Flag.find(@flag3.id)
          end

          should_set_the_flash_to /success/
          should_assign_to :flag
          should_respond_with :redirect
          should_redirect_to("Flags index page") { flags_url }
          should "update the flag" do
            assert_equal "Some reason", @flag1.response
            assert_equal FLAG_STATUS_RESOLVED_MANUALLY, @flag1.status
            assert "Some reason" != @flag2.response
            assert_equal FLAG_STATUS_PENDING, @flag2.status
            assert "Some reason" != @flag3.response
            assert_equal FLAG_STATUS_PENDING, @flag3.status

            assert COMMENT_STATUS_ACTIVE, @flag1.flaggable.status
            assert COMMENT_STATUS_ACTIVE, @flag2.flaggable.status
            assert COMMENT_STATUS_ACTIVE, @flag3.flaggable.status
          end
        end

        context "on PUT to :update to upon the flag with status resolved automatically" do
          setup do
            put :update, :id => @flag1, :flag => { :response => "Some reason", :status => FLAG_STATUS_RESOLVED }
            @flag1 = Flag.find(@flag1.id)
            @flag2 = Flag.find(@flag2.id)
            @flag3 = Flag.find(@flag3.id)
          end

          should_set_the_flash_to /rejected/
          should_assign_to :flag
          should_respond_with :redirect
          should_redirect_to("Flags index page") { flags_url }
          should "update the flag" do
            assert_equal "Some reason", @flag1.response
            assert_equal FLAG_STATUS_RESOLVED, @flag1.status
            assert "Some reason" != @flag2.response
            assert_equal FLAG_STATUS_RESOLVED, @flag2.status
            assert "Some reason" != @flag3.response
            assert_equal FLAG_STATUS_PENDING, @flag3.status

            assert COMMENT_STATUS_REJECTED, @flag1.flaggable.status
            assert COMMENT_STATUS_REJECTED, @flag2.flaggable.status
            assert COMMENT_STATUS_ACTIVE, @flag3.flaggable.status
          end
        end
      end

      context "on GET to :index" do
        setup { get :index }

        should_assign_to :flags
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "index"
      end
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

    context "given an existing user" do
      setup do
        @profile_user = Factory.create(:user)
      end

      context "on GET to :new" do
        setup { get :new, :flagger_type => 'User', :flagger_id => @profile_user }

        should_assign_to :flag
        should_assign_to :flagger
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "new"
      end

      context "on POST to :create" do
        setup do
          assert Flag.all.empty?
          @new_flag_attr = Factory.attributes_for(:flag, :flaggable_id => @profile_user.id)
          post :create, :flag => @new_flag_attr, :flagger_type => 'User', :flagger_id => @profile_user
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
            post :create, :flag => @new_flag_attr, :flagger_type => 'User', :flagger_id => @profile_user
          end

          should_assign_to :flagger
          should_respond_with :success
          should_render_template :new
        end
      end
    end
  end
end
