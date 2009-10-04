require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class LessonsControllerTest < ActionController::TestCase

  fast_context "while not logged in" do

    fast_context "on GET to :index" do
      setup { get :index }

      should_assign_to :lessons
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "index"
    end

    fast_context "on GET to :show in a not-ready state" do
      setup do
        assert LessonVisit.all.empty?
        @lesson = Factory.create(:lesson)
        assert !@lesson.ready?
        get :show, :id => @lesson.id
      end

      should_assign_to :lesson
      should_respond_with :redirect
      should_set_the_flash_to /not available/
      should "not populate lesson visit" do
        assert LessonVisit.all.empty?
      end
    end

    fast_context "on GET to :show with a lesson in the ready state" do
      setup do
        assert LessonVisit.all.empty?
        @lesson = Factory.create(:lesson)
        @lesson. update_attribute(:status, LESSON_STATUS_READY)
        assert @lesson.ready?
        get :show, :id => @lesson.id
      end

      should_assign_to :lesson
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "show"
      should "populate lesson visit" do
        assert_equal 1, LessonVisit.all.size
      end
    end

#    context "with a lesson defined" do
#      setup do
#        @lesson = Factory.create(:lesson)
#        assert !@lesson.nil?
#      end
#
#      context "on GET to :search" do
#        setup { get :search, :search_lesson_criteria => "test" }
#
#        should_assign_to :lessons
#        should_respond_with :success
#        should "retrieve a lesson" do
#          assert_equal 1, assigns(:lessons).size
#        end
#        should_not_set_the_flash
#        should_render_template "search"
#      end
#    end

    fast_context "on GET to :new when not an instructor" do
      setup { get :new }

      should_not_assign_to :lesson
      should_respond_with :redirect
      should_set_the_flash_to /You must be logged in/
      should_redirect_to("login page") { new_user_session_url }
    end
  end

  fast_context "when logged in" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "on GET to :index" do
      setup { get :index }
      should_respond_with :redirect
      should_redirect_to("home page") { home_path }
    end

    fast_context "on GET to :new when not an instructor" do
      setup { get :new }

      should_not_assign_to :lesson
      should_respond_with :redirect
      should_set_the_flash_to :must_be_instructor
      should_redirect_to("first wizard step") {instructor_signup_wizard_account_path(@user) }
    end

    fast_context "when an instructor" do
      setup do
        set_instructor
        assert @user.verified_instructor?
      end

      fast_context "on GET to :new" do
        setup { get :new }

        should_assign_to :lesson
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "new"
      end
    end

    # Don't know how to mock this up with a paperclip file attachment'
    #fast_context "on POST to :create" do
    #setup do
    #  post :create, :lesson => Factory.attributes_for(:lesson)
    #end
    #
    #should_assign_to :lesson
    #should_respond_with :redirect
    #should_set_the_flash_to :lesson_updated
    #should_redirect_to("lessons index page") { lesson_url(assigns(:lesson)) }
    #end

    fast_context "on POST to :create with bad values" do
      setup do
        set_instructor
        assert @user.verified_instructor?
        post :create, :lesson => Factory.attributes_for(:lesson, :title => "")
      end

      should_assign_to :lesson
      should_render_template :new
      should_not_set_the_flash
    end

    fast_context "with at least one existing lesson" do
      setup do
        Factory.create(:user)
        @lesson = Factory.create(:lesson)
        @lesson.instructor = @user
        @lesson.save!
        @original_video = Factory.create(:original_video, :lesson => @lesson)
        @lesson = Lesson.find(@lesson)
        assert @lesson.original_video
      end

      fast_context "as a moderator" do
        setup { @user.has_role 'moderator'}

        fast_context "on POST to :unreject" do
          setup do
            @status = @lesson.status
            assert @lesson
            post :unreject, :id => @lesson.id
            @lesson = Lesson.find(@lesson)
          end

          should_assign_to :lesson
          should_respond_with :redirect
          should_set_the_flash_to :unreject_failed
          should_redirect_to("lesson page") { lesson_path(@lesson) }
          should "not have changed lesson status" do
            assert_equal @status, @lesson.status
          end
        end

        fast_context "with lesson in rejected status" do
          setup { @lesson.update_attribute(:status, LESSON_STATUS_REJECTED) }

          fast_context "on POST to :unreject" do
            setup do
              @status = @lesson.status
              post :unreject, :id => @lesson.id
              @lesson = Lesson.find(@lesson)
            end

            should_assign_to :lesson
            should_respond_with :redirect
            should_set_the_flash_to :unrejected
            should_redirect_to("lesson page") { lesson_path(@lesson) }
            should "have changed lesson status" do
              assert_equal LESSON_STATUS_PENDING, @lesson.status
            end
          end
        end
      end

      fast_context "and not an admin" do
        fast_context "on POST to :convert" do
          setup { post :convert, :id => @lesson }

          should_not_assign_to :lesson
          should_redirect_to("lessons index") { lessons_path }
          should_set_the_flash_to /Permission denied/
        end
      end

      fast_context "with admin access" do
        setup do
          @user.has_role 'admin'
        end

        fast_context "on POST to :convert" do
          setup { post :convert, :id => @lesson }

          should_assign_to :lesson
          should_redirect_to("lesson page") { lesson_path(@lesson) }
          should_set_the_flash_to /Video conversion started/
        end

        fast_context "on GET to :list_admin" do
          setup { post :list_admin }

          should_assign_to :lessons
          should_render_template 'list'
          should_not_set_the_flash
        end
      end

      fast_context "on GET to :edit" do
        setup { get :edit, :id => @lesson }
        should_assign_to :lesson
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "edit"
      end

      fast_context "on PUT to :update" do
        setup { put :update, :id => @lesson.id, :lesson => Factory.attributes_for(:lesson) }

        should_set_the_flash_to :lesson_updated
        should_assign_to :lesson
        should_respond_with :redirect
        should_redirect_to("lesson page") { lesson_path(@lesson) }
      end

      fast_context "on PUT to :update with bad values" do
        setup { put :update, :id => @lesson.id, :lesson => Factory.attributes_for(:lesson, :title => "") }

        should_not_set_the_flash
        should_assign_to :lesson
        should_respond_with :success
        should_render_template :edit
      end

      fast_context "which was authored by a different user" do
        setup do
          @lesson.instructor = Factory.create(:user, :email => 'some@other.com')
          @lesson.save!
        end

        fast_context "on GET to :edit" do
          setup { get :edit, :id => @lesson }
          should_assign_to :lesson
          should_redirect_to("lesson page") { lesson_path(@lesson) }
          should_set_the_flash_to /do not have access/
        end

        fast_context "on PUT to :update" do
          setup { put :update, :id => @lesson.id, :lesson => Factory.attributes_for(:lesson) }
          should_assign_to :lesson
          should_redirect_to("lesson page") { lesson_path(@lesson) }
          should_set_the_flash_to /do not have access/
        end
      end
    end
    fast_context "with a lesson with free credits" do
      setup do
        @sku = Factory.create(:credit_sku, :sku => FREE_CREDIT_SKU)
        @lesson = Factory.create(:lesson, :initial_free_download_count => 5)
        @lesson.update_attribute(:status, LESSON_STATUS_READY)
        @user.wishes << @lesson
        assert @user.on_wish_list?(@lesson)
        assert_equal 5, @lesson.free_credits.available.size
        get :watch, :id => @lesson
      end

      should_assign_to :lesson
      should_not_set_the_flash
      should_redirect_to("watch screen") { lesson_path(@lesson) }

      should "have 4 free credits" do
        assert_equal 4, @lesson.free_credits.available.size
      end
      should "does not wish for the lesson" do
        assert !@user.on_wish_list?(@lesson)
      end
    end

    fast_context "with a lesson" do
      setup do
        @lesson = Factory.create(:lesson)
      end

      fast_context "which the user already owns" do
        setup do
          @lesson.update_attribute(:status, LESSON_STATUS_READY)
          @lesson = assign_video(@lesson)
          assert @lesson.full_processed_video
          assert @lesson.full_processed_video.url
          @user.credits.create!(:price => 0.99, :lesson => @lesson)
          assert @user.owns_lesson?(@lesson)
          get :show, :id => @lesson
        end

        should_assign_to :lesson
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "show"
      end

      fast_context "for which the user is the instructor" do
        setup do
          @lesson.update_attribute(:status, LESSON_STATUS_READY)
          @lesson = assign_video(@lesson)
          @lesson.update_attribute(:instructor, @user)
          assert !@user.owns_lesson?(@lesson)
          get :show, :id => @lesson
        end

        should_assign_to :lesson
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "show"
      end

      fast_context "with no available credits" do
        setup do
          @lesson.update_attribute(:status, LESSON_STATUS_READY)
          get :watch, :id => @lesson
        end

        should_set_the_flash_to I18n.t('lesson.need_credits')
        should_redirect_to("online store") { store_path(1) }
      end

      fast_context "with available credits" do
        setup do
          @user.credits.create!(:price => 0.99)
          assert !@user.available_credits.empty?
          assert !@user.owns_lesson?(@lesson)
          @lesson.update_attribute(:status, LESSON_STATUS_READY)
          get :watch, :id => @lesson
          assert @lesson.ready?
        end

        should_assign_to :lesson
        should_not_set_the_flash
        should_redirect_to("redeem credit confirmation screen") { new_acquire_lesson_path(:id => @lesson) }
      end

      fast_context "and credit is not ready" do
        setup do
          get :watch, :id => @lesson
        end

        should_assign_to :lesson
        should_set_the_flash_to /not available/
        should_redirect_to("show lesson page") { lesson_path(:id => @lesson) }
      end
    end
  end

  def assign_video(lesson)
    video = Factory.create(:ready_full_processed_video, :lesson => lesson)
    Lesson.find(lesson.id)
  end

  def set_instructor
    @user.author_agreement_accepted_on = Time.now
    @user.payment_level = Factory.create(:payment_level)
    @user.address1 = "xxx"
    @user.city = "yyy"
    @user.state = "XXX"
    @user.postal_code = "99999"
    @user.country = "US"
    @user.verified_address_on = Time.now
    @user.save!
    @user = User.find(@user)
  end
end