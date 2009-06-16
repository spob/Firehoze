require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "on GET to :new" do
      setup { get :new }

      should_assign_to :order
      should_respond_with :success
      should_not_set_the_flash
      should_render_template "new"
    end

    context "on POST to :create" do
      setup do
        post :create, :order => Factory.attributes_for(:order, :card_number => "1")
      end

      should_assign_to :order
      should_respond_with :redirect
      should_set_the_flash_to :order_placed
      should_redirect_to("show order page") { order_url(assigns(:order)) }
      should "set the order transaction" do
        assert_equal "Bogus Gateway: Forced success", assigns(:order).last_transaction.first.message
      end  
    end

    context "on POST to :create that will fail" do
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
