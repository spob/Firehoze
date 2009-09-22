require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class ContactUsersControllerTest < ActionController::TestCase
  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create(@user)
    end

    fast_context "sending to a user who disallows contact" do
      setup { @to_user = Factory.create(:user) }

      fast_context "on GET to :new" do
        setup { get :new, :id => @to_user }

        should_assign_to :to_user
        should_respond_with :redirect
        should_set_the_flash_to /This user's privacy settings prevent you from contacting/
        should_redirect_to("user show page") { user_path(@to_user) }
      end

      fast_context "on POST to :create" do
        setup { post :create, :id => @to_user, :subject => "Blah", :msg => "this is the msg" }

        should_assign_to :to_user
        should_respond_with :redirect
        should_set_the_flash_to /This user's privacy settings prevent you from contacting/
        should_redirect_to("user show page") { user_path(@to_user) }
      end
    end

    fast_context "sending to a user who allows contact" do
      setup { @to_user = Factory.create(:user, :allow_contact => USER_ALLOW_CONTACT_ANYONE) }

      fast_context "on GET to :new" do
        setup { get :new, :id => @to_user }

        should_assign_to :to_user
        should_respond_with :success
        should_not_set_the_flash
        should_render_template 'new'
      end

      fast_context "on POST to :create" do
        setup { post :create, :id => @to_user, :subject => "Blah", :msg => "this is the msg" }

        should_assign_to :to_user
        should_respond_with :redirect
        should_set_the_flash_to /message.*sent/
        should_redirect_to("user show page") { user_path(@to_user) }
      end
    end
  end
end