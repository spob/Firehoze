require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class CategoriesControllerTest < ActionController::TestCase
  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "without moderator access" do
      context "on GET to :index" do
        setup { get :index }

        should_respond_with :redirect
        should_set_the_flash_to /Permission denied/
        should_redirect_to("home page") { lessons_path }
      end
    end

    fast_context "with admin access" do
      setup { @user.has_role 'admin' }

      fast_context "with existing categories" do
        setup { @category = Factory.create(:category) }
        subject { @category }

        fast_context "on GET to :index" do
          setup { get :index }

          should_assign_to :categories
          should_assign_to :category
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "index"
        end
      end
    end
  end
end