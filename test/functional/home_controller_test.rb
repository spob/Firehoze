require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'


class HomeControllerTest < ActionController::TestCase

  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "on GET to :show" do
      setup { get :show, :id => @user }

#      should_assign_to :user
#      should_respond_with :success
#      should_render_template "show"
      should_redirect_to("my firehoze") { my_firehoze_index_path }
      should_not_set_the_flash
    end
  end
end
