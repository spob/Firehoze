require File.dirname(__FILE__) + '/../test_helper'

class AdminConsolesControllerTest < ActionController::TestCase
  context "when logged in" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      @other_user = Factory(:user)
      UserSession.create @user
    end

    context "on GET to :index" do
      setup { get :index }

      should_respond_with :redirect
      should_not_set_the_flash
      should_redirect_to("home page")  { list_users_path }
    end

    context "as an admin" do
      setup { @user.is_admin }

      context "on GET to :index" do
        setup { get :index }

        should_respond_with :redirect
        should_not_set_the_flash
        should_redirect_to("home page")  { list_users_path }
      end
    end

    context "as an moderator" do
      setup { @user.is_moderator }

      context "on GET to :index" do
        setup { get :index }

        should_respond_with :redirect
        should_not_set_the_flash
        should_redirect_to("flags page")  { flags_path }
      end
    end

    context "as a payment mgr" do
      setup { @user.is_paymentmgr }

      context "on GET to :index" do
        setup { get :index }

        should_respond_with :redirect
        should_not_set_the_flash
        should_redirect_to("payments page")  { payments_path }
      end
    end
  end
end
