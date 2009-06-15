require 'test_helper'

class CartTest < ActiveSupport::TestCase
  context "given an existing record for a cart" do
    setup { @cart = Factory.create(:line_item).cart }

    should_belong_to :user
    should_validate_presence_of      :user

    context "with multiple lines" do
      setup do
        line_item_new = LineItem.new(:quantity => 11, :unit_price => 1.25,
                                     :discounted_unit_price => 1.15)
        line_item_new.sku = Factory.create(:credit_sku)
        @cart.line_items << line_item_new
        @cart.save!
      end

      should "calculate the total price" do
        for li in @cart.line_items do
          #puts "#{li.quantity} x $#{li.unit_price}, #{li.total_full_price}, #{li.total_discounted_price}"
        end
        assert_equal 2, @cart.line_items.count
        calculated_price = 5*0.99 + 11*1.25
        #puts "==========#{@cart.total_full_price}, #{@cart.total_discounted_price}, #{calculated_price}"
        assert_equal calculated_price, @cart.total_full_price
        assert_equal @cart.total_full_price, @cart.total_discounted_price
      end
    end

    context "with a defined user" do
      setup { @user = Factory(:user) }

      should "have a user" do
        assert_not_nil @user
      end

      context "and the order has not yet been purchased" do
        setup { @cart.purchased_at = nil }

        should "have a blank purchased_at date" do
          assert_nil @cart.purchased_at
        end

        context "after purchasing the cart" do
          setup {  @cart.execute_order_on_cart @user }

          before_should "start with zero credtis for the user" do
            assert @user.credits.empty?
          end

          should "execute the execute orders method" do
            assert_not_nil @cart.purchased_at
            assert 1, @user.credits.count
          end
        end
      end
    end
  end
end
