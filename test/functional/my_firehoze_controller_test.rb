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

    # fast_context "on GET to :my_stuff by owned pane" do
    #   setup { get :my_stuff, :pane => "owned" }
    # 
    #   should_assign_to :user
    #   should_not_assign_to :latest_browsed
    #   should_assign_to :owned
    #   should_not_assign_to :wishlist
    #   should_not_assign_to :reviews
    #   should_assign_to :groups
    #   should_assign_to :followed_instructors
    #   should_respond_with :success
    #   should_not_set_the_flash
    #   should_render_template "my_stuff"
    # end
    # 
    # fast_context "on GET to :my_stuff by latest_browsed pane" do
    #   setup { get :my_stuff, :pane => "latest_browsed" }
    # 
    #   should_assign_to :user
    #   should_assign_to :latest_browsed
    #   should_not_assign_to :owned
    #   should_not_assign_to :wishlist
    #   should_not_assign_to :reviews
    #   should_assign_to :groups
    #   should_assign_to :followed_instructors
    #   should_respond_with :success
    #   should_not_set_the_flash
    #   should_render_template "my_stuff"
    # end

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
      should_assign_to :used_credits
      should_assign_to :available_credits
      should_assign_to :expired_credits
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "account_history"
    end
  end
end