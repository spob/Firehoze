require 'test_helper'

class DiscountTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @discount = Factory.create(:discount_by_volume)
    end

    should_have_many                 :line_items
    should_validate_presence_of      :sku
    should "default active to true" do
      assert @discount.active
    end

    context "not referenced by line items" do
      should "allow delete" do
        assert @discount.can_delete?
      end
    end

    context "referenced by line items" do
      setup do
        @li = Factory.create(:line_item, :quantity => 20, :sku => @discount.sku)
      end

      should "not allow delete" do
        assert_equal 1, @discount.line_items.count
        assert !@discount.can_delete?
      end
    end
  end
end
