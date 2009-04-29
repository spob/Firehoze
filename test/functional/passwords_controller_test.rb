require 'test_helper'

class PasswordsControllerTest < ActionController::TestCase

  context "when logged in" do
    setup do
      activate_authlogic
      UserSession.create Factory(:user)
    end


    context "on GET to :edit" do
      setup { get :edit, :id => Factory(:user).id }

      should_assign_to :user
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "edit"
    end

    context "on PUT to :update" do
      setup { put :update, :id => Factory(:user).id,
              :user => {:current_password => "xxxxx",
                      :password => "xxxxx2",
                      :password_confirmation => "xxxxx2" } }

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to "Password updated!"
      should_redirect_to("profile page") { profile_url(assigns(:user)) }
    end

    context "on PUT to :update with bad current password" do
      setup { put :update, :id => Factory(:user).id,
              :user => {:current_password => "xyyy",
                      :password => "xxxxx2",
                      :password_confirmation => "xxxxx2" } }

      should_assign_to :user
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "edit"
    end

    context "on PUT to :update with blank current password" do
      setup { put :update, :id => Factory(:user).id,
              :user => {:password => "xxxxx2",
                      :password_confirmation => "xxxxx2" } }

      should_assign_to :user
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "edit"
    end

    context "on PUT to :update with unmatching new passwords" do
      setup { put :update, :id => Factory(:user).id,
              :user => {:current_password => "xxxxx",
                      :password => "xxxxx2",
                      :password_confirmation => "xxxxx3" } }

      should_assign_to :user
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "edit"
    end
  end
end
