require 'test_helper'

class UserLogonsControllerTest < ActionController::TestCase
  context "when logged on" do
    setup do
      activate_authlogic
      UserSession.create Factory(:user)
    end

    context "on GET to :index" do
      setup { get :index }

      should_assign_to :user_logons
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "index"
    end
  end
end
