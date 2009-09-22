require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class CartsControllerTest < ActionController::TestCase

  fast_context "when logged in" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "on GET to :show" do
      setup { get :show, :id => Factory.create(:cart) }

      should_assign_to :cart
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "show"
    end
  end
end
