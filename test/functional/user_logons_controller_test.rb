require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class UserLogonsControllerTest < ActionController::TestCase

  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "with admin access" do
      setup do
        @user.has_role 'admin'
      end

      fast_context "on GET to :index" do
        setup { get :index }

        should_assign_to :user_logons
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "index"
      end
    end

    fast_context "without admin access" do
      fast_context "on GET to :index" do
        setup { get :index }

        should_not_assign_to :user_logons
        should_respond_with :redirect
        should_set_the_flash_to /denied/
        should_redirect_to("lessons index") { lessons_url }
      end
    end
  end
end
