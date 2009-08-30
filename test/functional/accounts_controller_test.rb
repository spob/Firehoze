require File.dirname(__FILE__) + '/../test_helper'

class AccountsControllerTest < ActionController::TestCase

  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory.create(:user)
      UserSession.create(@user)
    end

    context "on GET to :show" do
      setup { get :show, :id => @user }

      should_assign_to :user
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "show"
    end

    context "on POST to clear_avatar" do
      setup { post :clear_avatar, :id => @user }

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to :avatar_cleared
      should_redirect_to("edit account page") { edit_account_path(assigns(:user)) }
    end

    context "on GET to :edit" do
      setup { get :edit, :id => Factory(:user).id }

      should_assign_to :user
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "edit"
    end

    context "on PUT to :update" do
      setup { put :update, :id => @user, :user => Factory.attributes_for(:user) }

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to :profile_update_success
      should_redirect_to("edit account page") { edit_account_path(assigns(:user)) }
    end

    context "on PUT to :update_privacy" do
      setup do
        assert !@user.show_real_name
        put :update_privacy, :id => @user, :user => { :show_real_name => true }
        @user = User.find(@user)
      end

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to :profile_update_success
      should_redirect_to("edit account page") { edit_account_path(assigns(:user)) }
      should "set show real name" do
        assert @user.show_real_name
      end
    end

    context "on PUT to :update with bad value" do
      setup { put :update, :id => @user, :user => Factory.attributes_for(:user, :last_name => "") }

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to I18n.t('account_settings.update_error')
      should_redirect_to("edit account screen") { edit_account_path(assigns(:user)) }
    end

    context "on GET to :instructor_signup_wizard" do
      setup { get :instructor_signup_wizard, :id => @user }

      should_assign_to :user
      should_respond_with :redirect
      should_not_set_the_flash
      should_redirect_to("first wizard step") {instructor_wizard_step1_account_path(assigns(:user)) }
    end
  end
end