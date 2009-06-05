require 'test_helper'

class CartTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @cart = Factory.create(:line_item).cart
    end

    context "with multiple lines" do
      setup do
        @cart.line_items << LineItem.new(:quantity => 11, :unit_price => 1.25, :sku => Factory.create(:credit_sku),
                :discounted_unit_price => 1.15)
        @cart.save!
      end

      should "calculate the total price" do
        #        for li in @cart.line_items do
        #          puts "#{li.quantity} x $#{li.unit_price}"
        #        end
        assert_equal 2, @cart.line_items.count
        assert_equal ((1 * 0.99) + (11 * 1.25)), @cart.total_full_price
        assert_equal ((1 * 0.99) + (11 * 1.25)), @cart.total_discounted_price
      end

      should "calculate the total credits" do
        assert_equal 12, @cart.total_credits
      end
    end
  end
end
