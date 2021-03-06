require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class OrdersControllerTest < ActionController::TestCase
  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "on GET to :new" do
      setup { get :new }

      should_assign_to :order
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    fast_context "on GET to :show when not the owner" do
      setup { get :show, :id => Factory.create(:completed_order) }

      should_assign_to :order
      should_respond_with :redirect
      should_set_the_flash_to /You can only view orders that you placed/
      should_redirect_to("home page") { home_url }
    end

    fast_context "on GET to :show" do
      setup { get :show, :id => Factory.create(:completed_order, :user => @user) }

      should_assign_to :order
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "show"
    end

    fast_context "on GET to :index" do
      setup { get :index }

      should_not_assign_to :orders
      should_respond_with :redirect
      should_set_the_flash_to /Permission denied/
    end

    fast_context "as an admin" do
      setup do
        @user.has_role 'admin'
        assert @user.is_admin?
      end

      fast_context "on GET to :index" do
        setup { get :index }

        should_assign_to :orders
        should_respond_with :success
        should_not_set_the_flash
      end
    end

    fast_context "on POST to :create" do
      setup do
        @jobcount = PeriodicJob.count
        post :create, :order => Factory.attributes_for(:order, :card_number => "1")
      end

      should_assign_to :order
      should_respond_with :redirect
      should_set_the_flash_to :order_placed
      should_redirect_to("show order page") { order_url(assigns(:order)) }
      should "set the order transaction" do
        assert_equal "Bogus Gateway: Forced success", assigns(:order).last_transaction.first.message
      end
      should "have a periodic job" do
        assert @jobcount + 1, PeriodicJob.all.size
      end
    end

    fast_context "on POST to :create that will fail" do
      setup do
        post :create, :order => Factory.attributes_for(:order, :card_number => "2")
      end

      should_assign_to :order
      should_render_template "new"
      should_set_the_flash_to :order_placed
      should "set the order transaction" do
        assert_equal "Bogus Gateway: Forced failure", assigns(:order).last_transaction.first.message
      end
    end
  end
end
