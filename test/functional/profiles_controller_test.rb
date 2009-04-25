require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase

  context "when logged on" do
    setup do
      activate_authlogic
      UserSession.create Factory(:user)
    end

    context "on GET to :show" do
      setup { get :show }

      should_assign_to :user
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "show"
    end

    context "on GET to :edit" do
      setup { get :edit, :id => Factory(:user).id }

      should_assign_to :user
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "edit"
    end

    context "on PUT to :update" do
      setup { put :update, :user => Factory.attributes_for(:user) }

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to "Profile updated!"
      should_redirect_to("profile page") { profile_url(assigns(:user)) }
    end

    context "on GET to :edit_password" do
      setup { get :edit_password, :id => Factory(:user).id }

      should_assign_to :user
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "edit_password"
    end
  end
end
