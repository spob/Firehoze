require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'
require "authlogic/test_case"

class UserSessionsControllerTest < ActionController::TestCase

  fast_context "given a user" do
    setup do
      @user = Factory.create(:user)
      activate_authlogic
    end

    fast_context "on GET to :new" do
      setup { get :new }
      should_assign_to :user_session
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    fast_context "on POST to :create with valid credentials" do
      logons = UserLogon.count
      setup do
        @logon_count = UserLogon.count
        post :create, :user_session => { :login => @user.login, :password => "xxxxx" }
      end

      should_assign_to :user_session
      should "should create user session" do
        assert_equal @user, UserSession.find.user
      end
      should_redirect_to("my firehoze") { my_firehoze_index_path }
      should_respond_with :redirect
      should "persist a new user logon audit trail record" do
        assert_equal @logon_count + 1, UserLogon.count
      end
    end

    fast_context "on POST to :create with invalid credentials" do
      setup { post :create, :user_session => { :email => @user.email, :password => "badpassword" } }

      should_assign_to :user_session
      should_not_set_the_flash
      should_render_template "new"
      should "not persist the session" do
        assert assigns(:user_session).new_record?
      end
    end

    fast_context "on DELETE to :destroy" do
      setup { delete :destroy }

      should_redirect_to("login page") { new_user_session_path }
      should "not have a session" do
        assert_nil UserSession.find
      end
    end
  end
end
