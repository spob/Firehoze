require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @line_item = Factory.create(:line_item)
    end

    should_belong_to                 :discount
    should_have_many                 :gift_certificates
    should_validate_presence_of      :unit_price, :sku, :cart, :quantity
    # can't do should_validate_presence_of for discounted_unit_price because it's set implicitly'
    should_allow_values_for          :unit_price, 0.99, 1, 1.23, 1000.2
    should_allow_values_for          :discounted_unit_price, 0.99, 1, 1.23, 1000.2
    should_allow_values_for          :quantity, 1, 5

    # Apparently should not allow values for only works if you pass the error message you expect
    # to see...though this is not clear in the shoulda documentation.
    should_not_allow_values_for      :unit_price, -2.12, 0, :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
    should_not_allow_values_for      :unit_price, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')

    # can't test the following because discounted_unit_price is set automatically'
    #    should_not_allow_values_for      :discounted_unit_price, -2.12, 0, :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
    #    should_not_allow_values_for      :discounted_unit_price, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')

    should_not_allow_values_for      :quantity, 0, -1, :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
    should_not_allow_values_for      :quantity,  2.12, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')

    should "calculate total price" do
      assert_equal 0.99*5, @line_item.total_full_price
    end

    should "calculate discounted price" do
      assert_equal 0.99*5, @line_item.total_discounted_price
    end

    should "find by cart and sku" do
      assert_equal @line_item, LineItem.by_cart(@line_item.cart.id).by_sku(@line_item.sku.id).first
    end
  end

  context "given a range of discounts" do
    setup do
      @sku = Factory.create(:credit_sku)
      @discount5 = Factory.create(:discount_by_volume, :minimum_quantity => 5, :percent_discount => 0.05, :sku => @sku)
      @discount10 = Factory.create(:discount_by_volume, :minimum_quantity => 10, :percent_discount => 0.10, :sku => @sku)
      @discount20 = Factory.create(:discount_by_volume, :minimum_quantity => 20, :percent_discount => 0.20, :sku => @sku)
    end

    context "and a line item with quantity less than the first price break" do
      setup { @line_item = Factory.create(:line_item, :quantity => 3, :sku => @sku) }

      should "have no discount" do
        assert_nil @line_item.discount
        assert_equal @line_item.total_full_price, @line_item.total_discounted_price
      end
    end

    context "and a line item with quantity equal to the first price break" do
      setup { @line_item = Factory.create(:line_item, :quantity => 5, :sku => @sku) }

      should "create a line with a 5% discount" do
        verify_discount @line_item, 0.05
      end
    end

    context "and a line item with quantity slightly greater than the first price break" do
      setup { @line_item = Factory.create(:line_item, :quantity => 7, :sku => @sku) }

      should "create a line with a 5% discount" do
        verify_discount @line_item, 0.05
      end
    end

    context "and a line item with quantity greater than the second price break" do
      setup { @line_item = Factory.create(:line_item, :quantity => 12, :sku => @sku) }

      should "create a line with a 10% discount" do
        verify_discount @line_item, 0.1
      end
    end

    context "and a line item with quantity equal to the third price break" do
      setup { @line_item = Factory.create(:line_item, :quantity => 20, :sku => @sku) }

      should "create a line with a 20% discount" do
        verify_discount @line_item, 0.2
      end
    end

    context "and a line item with quantity greater than the third price break" do
      setup { @line_item = Factory.create(:line_item, :quantity => 999, :sku => @sku) }

      should "create a line with a 20% discount" do
        verify_discount @line_item, 0.2
      end
    end
  end

  private

  def verify_discount(line_item, discount)
    assert_not_nil line_item.discount
    assert_equal discount, line_item.discount.percent_discount
    assert_equal((line_item.total_full_price * (1.0 - discount)).to_s, line_item.total_discounted_price.to_s)
  end
end
