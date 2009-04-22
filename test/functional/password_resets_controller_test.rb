require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase


  context "when not logged in" do
    setup do
      Factory(:user)
    end

    context "on GET to :new" do
      setup { get :new }

      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    context "on POST to :create" do
      setup { post :create, :email => Factory(:user).email }

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to /Instructions to reset your password/
      should_redirect_to("login page") { root_url }
    end
  end
end