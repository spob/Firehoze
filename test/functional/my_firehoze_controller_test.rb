require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class MyFirehozeControllerTest < ActionController::TestCase

  context "when logged on" do
    setup do
      activate_authlogic
      @active_user = Factory(:user)
      UserSession.create @active_user
    end

    context "on GET to :index" do
      setup { get :index }

      should_assign_to :user
      should_assign_to :activities
      should_assign_to :tweets
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "index"
    end

    context "on GET to :my_stuff" do
      setup { get :my_stuff }

      should_assign_to :user
#      should_assign_to :activities
#      should_assign_to :tweets
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "index"
    end
  end
end
