require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class AdminConsolesControllerTest < ActionController::TestCase
  fast_context "when logged in" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      @other_user = Factory(:user)
      UserSession.create @user
    end

    fast_context "on GET to :index" do
      setup { get :index }

      should_respond_with :redirect
      should_not_set_the_flash
      should_redirect_to("home page") { list_users_path }
    end

    fast_context "as an admin" do
      setup { @user.is_admin }

      context "on GET to :index" do
        setup { get :index }

        should_respond_with :redirect
        should_not_set_the_flash
        should_redirect_to("home page") { list_users_path('search[order]' => 'ascend_by_login') }
      end
    end

    fast_context "as an moderator" do
      setup { @user.is_moderator }

      context "on GET to :index" do
        setup { get :index }

        should_respond_with :redirect
        should_not_set_the_flash
        should_redirect_to("flags page") { flags_path }
      end
    end

    fast_context "as a payment mgr" do
      setup { @user.is_paymentmgr }

      context "on GET to :index" do
        setup { get :index }

        should_respond_with :redirect
        should_not_set_the_flash
        should_redirect_to("payments page") { payments_path }
      end
    end
  end
end
