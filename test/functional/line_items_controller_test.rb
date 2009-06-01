require 'test_helper'

class LineItemsControllerTest < ActionController::TestCase

  context "when not logged on" do
    context "on GET to :new" do
      setup { get :new }

      should_not_assign_to :sku
      should_respond_with :redirect
      should_set_the_flash_to /You must be logged in/
      should_redirect_to("login page") { new_user_session_url }
    end
  end

  context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    context "on POST to :create" do
      setup do
        @sku = Factory.create(:credit_sku)
        post :create, :sku_id => @sku, :quantity => 1
      end

      should_assign_to :line_item
      should_respond_with :redirect
      should_set_the_flash_to /Added.*cart/
      should_redirect_to("cart page") { '/cart' }
      should "create a new line item" do
        assert_equal 1, @sku.line_items.count
        assert_equal 1, @sku.line_items.first.quantity
      end

      context "and on another POST to :create for same SKU" do
        setup { post :create, :sku_id => @sku, :quantity => 3 }
        should_assign_to :line_item
        should_respond_with :redirect
        should_set_the_flash_to /Added.*cart/
        should_redirect_to("cart page") { '/cart' }
        should "increment existing line item" do
          assert_equal 1, @sku.line_items.count
          assert_equal 4, @sku.line_items.first.quantity
        end

        context "and yet one more POST to :create with a different SKU" do
          setup do
            @sku2 = Factory.create(:credit_sku)
            post :create, :sku_id => @sku2, :quantity => 1
          end
          should_assign_to :line_item
          should_respond_with :redirect
          should_set_the_flash_to /Added.*cart/
          should_redirect_to("cart page") { '/cart' }
          should "create a new line item" do
            assert_equal 1, @sku.line_items.count
            assert_equal 4, @sku.line_items.first.quantity
            assert_equal 1, @sku2.line_items.count
            assert_equal 1, @sku2.line_items.first.quantity
          end
        end
      end
    end
  end
end
