require 'test_helper'

class StoreControllerTest < ActionController::TestCase

  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "on GET to :show" do
      setup { get :show }

      should_respond_with :success
      should_not_set_the_flash
      should_render_template "show"
    end
  end
end
