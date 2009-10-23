require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class GroupsControllerTest < ActionController::TestCase
  fast_context "on GET to :index" do
    setup { get :index }
    should_respond_with :success
    should_not_set_the_flash
    should_assign_to :groups
    should_render_template 'index'
  end

  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "on GET to :new" do
      setup { get :new }

      should_assign_to :group
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    fast_context "on POST to :create" do
      setup do
        post :create, :group => Factory.attributes_for(:group)
      end

      should_set_the_flash_to /Successfully created group/
      should_assign_to :group
      should_respond_with :redirect
      should_redirect_to("Group index page") { groups_url }
    end
  end
end
