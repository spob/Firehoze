require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'


class MyFirehozeControllerTest < ActionController::TestCase

  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "on GET to :show" do
      setup { get :show, :id => @user }

      should_assign_to :user
      should_assign_to :activities
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "show"
    end
  end
end
