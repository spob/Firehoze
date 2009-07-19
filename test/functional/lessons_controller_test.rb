require 'test_helper'

class LessonsControllerTest < ActionController::TestCase

  context "while not logged in" do

    context "on GET to :index" do
      setup { get :index }

      should_assign_to :lessons
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "index"
    end

    context "on GET to :show" do
      setup { get :show, :id => Factory(:lesson).id }

      should_assign_to :lesson
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "show"
    end

    context "on GET to :new" do
      setup { get :new }

      should_not_assign_to :lesson
      should_respond_with :redirect
      should_set_the_flash_to /You must be logged in/
      should_redirect_to("login page") { new_user_session_url }
    end
  end

  context "when logged in" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "on GET to :index" do
      setup { get :index }

      should_assign_to :lessons
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "index"
    end

    context "on GET to :new" do
      setup { get :new }

      should_assign_to :lesson
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    # Don't know how to mock this up with a paperclip file attachment'
    #context "on POST to :create" do
      #setup do
      #  post :create, :lesson => Factory.attributes_for(:lesson)
      #end
      #
      #should_assign_to :lesson
      #should_respond_with :redirect
      #should_set_the_flash_to :lesson_updated
      #should_redirect_to("lessons index page") { lesson_url(assigns(:lesson)) }
    #end

    context "on POST to :create with bad values" do
      setup do
        post :create, :lesson => Factory.attributes_for(:lesson, :title => "")
      end

      should_assign_to :lesson
      should_render_template :new
      should_not_set_the_flash
    end

    context "with at least one existing lesson" do
      setup do
        Factory.create(:user)
        @lesson = Factory.create(:lesson)
        @lesson.instructor = @user
        @lesson.save!
        @original_video = Factory.create(:original_video, :lesson => @lesson)
        @lesson = Lesson.find(@lesson)
        assert @lesson.original_video
      end

      context "and not an admin" do
        context "on POST to :convert" do
          setup { post :convert, :id => @lesson }
          should_not_assign_to :lesson
          should_redirect_to("lessons index") { lessons_path }
          should_set_the_flash_to /Permission denied/
        end
      end

      context "with admin access" do
        setup do
          @user.has_role 'admin'
        end

        context "on POST to :convert" do
          setup { post :convert, :id => @lesson }

          should_assign_to :lesson
          should_redirect_to("lesson page") { lesson_path(@lesson) }
          should_set_the_flash_to /Video conversion started/
        end
      end

      context "on GET to :edit" do
        setup { get :edit, :id => @lesson }
        should_assign_to :lesson
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "edit"
      end

      context "on PUT to :update" do
        setup { put :update, :id => @lesson.id, :lesson => Factory.attributes_for(:lesson) }

        should_set_the_flash_to :lesson_updated
        should_assign_to :lesson
        should_respond_with :redirect
        should_redirect_to("lesson page") { lesson_path(@lesson) }
      end

      context "on PUT to :update with bad values" do
        setup { put :update, :id => @lesson.id, :lesson => Factory.attributes_for(:lesson, :title => "") }

        should_not_set_the_flash
        should_assign_to :lesson
        should_respond_with :success
        should_render_template :edit
      end

      context "which was authored by a different user" do
        setup do
          @lesson.instructor = Factory.create(:user, :email => 'some@other.com')
          @lesson.save!
        end

        context "on GET to :edit" do
          setup { get :edit, :id => @lesson }
          should_assign_to :lesson
          should_redirect_to("lesson page") { lesson_path(@lesson) }
          should_set_the_flash_to /do not have access/
        end

        context "on PUT to :update" do
          setup { put :update, :id => @lesson.id, :lesson => Factory.attributes_for(:lesson) }
          should_assign_to :lesson
          should_redirect_to("lesson page") { lesson_path(@lesson) }
          should_set_the_flash_to /do not have access/
        end
      end
    end
    context "with a lesson with free credits" do
      setup do
        @sku = Factory.create(:credit_sku, :sku => FREE_CREDIT_SKU)
        @lesson = Factory.create(:lesson, :initial_free_download_count => 5)
        @lesson.update_attribute(:status, VIDEO_STATUS_READY)
        assert_equal 5, @lesson.free_credits.available.size
        get :watch, :id => @lesson
      end

      should_assign_to :lesson
      should_not_set_the_flash
      should_redirect_to("watch screen") { watch_lesson_path(@lesson) }

      should "have 4 free credits" do
        assert_equal 4, @lesson.free_credits.available.size
      end
    end

    context "with a lesson" do
      setup do
        @lesson = Factory.create(:lesson)
      end

      context "which the user already owns" do
        setup do
          @lesson.update_attribute(:status, VIDEO_STATUS_READY)
          @lesson = assign_video(@lesson)
          assert @lesson.processed_videos.by_format('Flash').first
          assert @lesson.processed_videos.by_format('Flash').first.url
          @user.credits.create!(:price => 0.99, :lesson => @lesson)
          assert @user.owns_lesson?(@lesson)
          get :watch, :id => @lesson
        end

        should_assign_to :lesson
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "watch"
      end

      context "for which the user is the instructor" do
        setup do
          @lesson.update_attribute(:status, VIDEO_STATUS_READY)
          @lesson = assign_video(@lesson)
          @lesson.update_attribute(:instructor, @user)
          assert !@user.owns_lesson?(@lesson)
          get :watch, :id => @lesson
        end

        should_assign_to :lesson
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "watch"
      end

      context "with no available credits" do
        setup do
          @lesson.update_attribute(:status, VIDEO_STATUS_READY)
          get :watch, :id => @lesson
        end

        should_set_the_flash_to I18n.t('lesson.need_credits')
        should_redirect_to("online store") { store_path(1) }
      end

      context "with available credits" do
        setup do
          @user.credits.create!(:price => 0.99)
          assert !@user.available_credits.empty?
          assert !@user.owns_lesson?(@lesson)
          @lesson.update_attribute(:status, VIDEO_STATUS_READY)
          get :watch, :id => @lesson
          assert @lesson.ready?
        end

        should_assign_to :lesson
        should_not_set_the_flash
        should_redirect_to("redeem credit confirmation screen") { new_acquire_lesson_path(:id => @lesson) }
      end

      context "and credit is not ready" do
        setup do
          get :watch, :id => @lesson
        end

        should_assign_to :lesson
        should_set_the_flash_to /Conversion in process/
        should_redirect_to("show lesson page") { lesson_path(:id => @lesson) }
      end
    end
  end

  def assign_video(lesson)
    video = Factory.create(:ready_processed_video, :lesson => lesson)
    Lesson.find(lesson.id)
  end
end