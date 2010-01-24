require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class PasswordsControllerTest < ActionController::TestCase

  fast_context "when logged in" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end


    #fast_context "on GET to :edit" do
    #  setup { get :edit, :id => Factory(:user).id }
    #
    #  should_assign_to :user
    #  should_respond_with :success
    #  should_not_set_the_flash
    #  should_render_template "edit"
    #end

    fast_context "on PUT to :update" do
      setup { put :update, :id => Factory(:user).id,
                  :user => {:current_password => "xxxxx",
                            :password => "xxxxx2",
                            :password_confirmation => "xxxxx2" } }

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to :pwd_update_success
      should_redirect_to("profile page") { edit_account_url(assigns(:user)) }
    end

    fast_context "on PUT to :update with bad current password" do
      setup { put :update, :id => Factory(:user).id,
                  :user => {:current_password => "xyyy",
                            :password => "xxxxx2",
                            :password_confirmation => "xxxxx2" } }

      should_assign_to :user
      should_not_set_the_flash
      should_respond_with :success
      should_render_template 'edit'
    end

    fast_context "on PUT to :update with blank current password" do
      setup { put :update, :id => Factory(:user).id,
                  :user => {:password => "xxxxx2",
                            :password_confirmation => "xxxxx2" } }

      should_assign_to :user
      should_not_set_the_flash
      should_respond_with :success
      should_render_template 'edit'
    end

    fast_context "on PUT to :update with unmatching new passwords" do
      setup { put :update, :id => Factory(:user).id,
                  :user => {:current_password => "xxxxx",
                            :password => "xxxxx2",
                            :password_confirmation => "xxxxx3" } }

      should_assign_to :user
      should_not_set_the_flash
      should_respond_with :success
      should_render_template 'edit'
    end
  end
end
