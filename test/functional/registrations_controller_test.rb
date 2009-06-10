require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase

  context "while not logged on" do

    context "on GET to :new" do
      setup { get :new }

      should_assign_to :registration
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    context "on POST to :create" do
      setup do
        post :create, :registration => Factory.attributes_for(:user)
      end

      #should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to /Please check your email/
      should_redirect_to("root  page") { root_path }
    end
  end
end