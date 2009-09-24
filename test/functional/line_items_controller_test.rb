require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class LineItemsControllerTest < ActionController::TestCase

  fast_context "when not logged on" do
    fast_context "on GET to :new" do
      setup do
        @sku = Factory.create(:credit_sku)
        post :create, :sku => @sku.sku, :quantity => 1
      end

      should_not_assign_to :sku
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

    fast_context "on POST to :create" do
      setup do
        @sku = Factory.create(:credit_sku)
        post :create, :sku => @sku.sku, :quantity => 1
      end

      should_assign_to :line_item
      should_respond_with :redirect
      should_set_the_flash_to /Added.*cart/
      should_redirect_to("cart page") { '/cart' }
      should "create a new line item" do
        assert_equal 1, @sku.line_items.count
        assert_equal 1, @sku.line_items.first.quantity
      end

      fast_context "and on another POST to :create for same SKU" do
        setup { post :create, :sku => @sku.sku, :quantity => 3 }
        should_assign_to :line_item
        should_respond_with :redirect
        should_set_the_flash_to /Added.*cart/
        should_redirect_to("cart page") { '/cart' }
        should "increment existing line item" do
          assert_equal 1, @sku.line_items.count
          assert_equal 4, @sku.line_items.first.quantity
        end

        fast_context "and yet one more POST to :create with a different SKU" do
          setup do
            @sku2 = Factory.create(:credit_sku)
            post :create, :sku => @sku2.sku, :quantity => 1
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

    fast_context "with at least one LineItem" do
      setup { @line_item = Factory.create(:line_item) }

      fast_context "on DELETE to :destroy" do
        setup { delete :destroy, :id => @line_item }

        should_change(:from => 1, :to => 0) {LineItem.count}
        should_respond_with :redirect
        should_set_the_flash_to /removed/
        should_redirect_to("cart page") { '/cart' }
      end

      fast_context "on PUT to :update to increment" do
        setup { put :update, :id => @line_item, :qty_change => 1 }

        should_change(:from => 5, :to => 6) { LineItem.find(@line_item).quantity }
        should_set_the_flash_to /Updated line item/

        fast_context "and another PUT to :update to increment" do
          setup { put :update, :id => @line_item, :qty_change => 1 }

          should_change(:from => 6, :to => 7) { LineItem.find(@line_item).quantity }
          should_set_the_flash_to /Updated line item/
        end

        fast_context "and another PUT to :update to decrement" do
          setup { put :update, :id => @line_item, :qty_change => -1 }

          should_change(:from => 6, :to => 5) { LineItem.find(@line_item).quantity }
          should_set_the_flash_to /Updated line item/

          fast_context "and another PUT to :update to decrement" do
            setup { put :update, :id => @line_item, :qty_change => -1 }

            should_not_change("The line item quantity") { LineItem.find(@line_item).quantity }
            should_set_the_flash_to /You must buy at least/
          end
        end
      end
    end
  end
end
