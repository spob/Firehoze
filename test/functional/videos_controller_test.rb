require 'test_helper'

class VideosControllerTest < ActionController::TestCase

  context "while not logged in" do

    context "on GET to :index" do
      setup { get :index }

      should_assign_to :videos
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "index"
    end

    context "on GET to :show" do
      setup { get :show, :id => Factory(:video).id }

      should_assign_to :video
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "show"
    end

    context "on GET to :new" do
      setup { get :new }

      should_not_assign_to :video
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

      should_assign_to :videos
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "index"
    end

    context "on GET to :new" do
      setup { get :new }

      should_assign_to :video
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    context "on POST to :create" do
      setup do
        post :create, :video => Factory.attributes_for(:video)
      end

      should_assign_to :video
      should_respond_with :redirect
      should_set_the_flash_to "Video uploaded"
      should_redirect_to("videos index page") { video_url(assigns(:video)) }
    end

    context "with at least one existing video" do

      setup do
        Factory.create(:user)
        @video = Factory.create(:video)
        @video.author = @user
        @video.save!
      end

      context "on GET to :edit" do
        setup { get :edit, :id => @video }
        should_assign_to :video
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "edit"
      end

      context "on PUT to :update" do
        setup { put :update, :id => @video.id, :video => Factory.attributes_for(:video) }

        should_set_the_flash_to "Video updated!"
        should_assign_to :video
        should_respond_with :redirect
        should_redirect_to("video page") { video_path(@video) }
      end

      context "which was authored by a different user" do
        setup do
          @video.author = Factory.create(:user, :email => 'some@other.com')
          @video.save!
        end

        context "on GET to :edit" do
          setup { get :edit, :id => @video }
          should_assign_to :video
          should_redirect_to("video page") { video_path(@video) }
          should_set_the_flash_to /do not have access/
        end

        context "on PUT to :update" do
          setup { put :update, :id => @video.id, :video => Factory.attributes_for(:video) }
          should_assign_to :video
          should_redirect_to("video page") { video_path(@video) }
          should_set_the_flash_to /do not have access/
        end
      end
    end
  end
end