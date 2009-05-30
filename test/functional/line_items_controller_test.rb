require 'test_helper'

class LineItemsControllerTest < ActionController::TestCase

  context "when not logged on" do
    context "on GET to :new" do
      setup { get :new }

      should_not_assign_to :sku
      should_respond_with :redirect
      should_set_the_flash_to /You must be logged in/
      should_redirect_to("login page") { new_user_session_url }
    end
  end

  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "on POST to :create" do
      setup { post :create, :sku_id => Factory.create(:credit_sku).id }

      should_assign_to :line_item
      should_respond_with :redirect
      should_set_the_flash_to /Added.*cart/
      should_redirect_to("cart page") { '/cart' }
    end
  end
end
