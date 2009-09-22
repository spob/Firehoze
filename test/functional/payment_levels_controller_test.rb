require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class PaymentLevelsControllerTest < ActionController::TestCase

  fast_context "when not logged on" do
    fast_context "on GET to :new" do
      setup { get :new }

      should_not_assign_to :payment_level
      should_respond_with :redirect
      should_set_the_flash_to /You must be logged in/
      should_redirect_to("login page") { new_user_session_url }
    end
  end

  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "with admin access" do
      setup do
        @user.has_role 'admin'
        @payment_level = Factory.create(:payment_level)
      end

      fast_context "on GET to :index" do
        setup { get :index }

        should_assign_to :payment_levels
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "index"
      end

      fast_context "on GET to :new" do
        setup { get :new }

        should_assign_to :payment_level
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "new"
      end

      fast_context "on POST to :create" do
        setup do
          PaymentLevel.delete_all
          post :create, :payment_level => Factory.attributes_for(:payment_level)
        end

        should_assign_to :payment_level
        should_respond_with :redirect
        should_set_the_flash_to /created/
        should_redirect_to("Payment levels index page") { payment_levels_url }
      end

      fast_context "with at least one existing payment level" do
        setup do
          PaymentLevel.delete_all
          assert PaymentLevel.all.empty?
          @payment_level = Factory.create(:payment_level)
        end

        fast_context "on GET to :edit" do
          setup { get :edit, :id => @payment_level }
          should_assign_to :payment_level
          should_respond_with :success
          should_not_set_the_flash
          should_render_template "edit"
        end

        fast_context "on PUT to :update" do
          setup { put :update, :id => @payment_level.id, :payment_level => Factory.attributes_for(:payment_level) }

          should_set_the_flash_to :payment_level_update_success
          should_assign_to :payment_level
          should_respond_with :redirect
          should_redirect_to("payment levels page") { payment_levels_path }
        end
      end
    end

    fast_context "without admin access" do
      fast_context "on GET to :index" do
        setup { get :index }

        should_not_assign_to :payment_levels
        should_respond_with :redirect
        should_set_the_flash_to /denied/
        should_redirect_to("Lesson index") { lessons_url }
      end
    end
  end
end
