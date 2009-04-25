require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  context "while not logged on" do

    context "on GET to :new" do
      setup { get :new }

      should_assign_to :user
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    context "on POST to :create" do
      setup do
        post :create, :user => Factory.attributes_for(:user)
      end

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to "Account registered!"
      should_redirect_to("user page") { user_url(assigns(:user)) }
    end
  end

  context "when logged on" do
    setup do
      activate_authlogic
      UserSession.create Factory(:user)
    end

    context "on GET to :show" do
      setup { get :show, :id => Factory(:user).id }

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
      setup { put :update, :id => Factory(:user).id, :user => Factory.attributes_for(:user) }

      should_assign_to :user
      should_respond_with :redirect
      should_set_the_flash_to "Account updated!"
      should_redirect_to("user page") { user_url(assigns(:user)) }
    end
  end
end
