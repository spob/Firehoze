require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class MyFirehozeControllerTest < ActionController::TestCase

  fast_context "when logged on" do
    setup do
      activate_authlogic
      @active_user = Factory(:user)
      UserSession.create @active_user
    end

    fast_context "on GET to :index" do
      setup { get :index }

      should_assign_to :user
      should_assign_to :activities
      should_assign_to :tweets
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "index"
    end

    fast_context "on GET to :my_stuff" do
      setup { get :my_stuff }

      should_assign_to :user
      should_assign_to :latest_browsed
      should_assign_to :owned
      should_assign_to :wishlist
      should_assign_to :reviews
      should_assign_to :groups 
      should_assign_to :followed_instructors     
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "my_stuff"
    end

    fast_context "on GET to :instructor" do
      setup { get :instructor }

      should_assign_to :instructed_lessons
      should_assign_to :students
      should_assign_to :payments     
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "instructor"
    end

    fast_context "on GET to :account_history" do
      setup { get :account_history }

      should_assign_to :orders
      should_assign_to :credits
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "account_history"
    end
  end
end