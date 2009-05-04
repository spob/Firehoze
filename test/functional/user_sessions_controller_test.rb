require 'test_helper'
require "authlogic/test_case"

class UserSessionsControllerTest < ActionController::TestCase
  context "given a user" do
    setup do
      @user = Factory.create(:user)
      activate_authlogic
    end

    context "on GET to :new" do
      setup { get :new }
      should_assign_to :user_session
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    context "on POST to :create with valid credentials" do
      logons = UserLogon.count
      setup { post :create, :user_session => { :email => @user.email, :password => "xxxxx" } }

      should_assign_to :user_session
      should "should create user session" do
        assert_equal @user, UserSession.find.user
      end
      should_redirect_to("home page")  { homes_path }
      should_respond_with :redirect
      should_set_the_flash_to "Login successful!"
      should "persist a new user logon audit trail record" do
        assert_equal logons + 1, UserLogon.count
      end
    end

    context "on POST to :create with invalid credentials" do
      setup { post :create, :user_session => { :email => @user.email, :password => "badpassword" } }

      should_assign_to :user_session
      should_not_set_the_flash
      should_render_template "new"
      should "not persist the session" do
        assert assigns(:user_session).new_record?
      end
    end

    context "on DELETE to :destroy" do
      setup { delete :destroy }

      should_redirect_to("login page") { new_user_session_path }
      should "not have a session" do
        assert_nil UserSession.find
      end
    end
  end
end
