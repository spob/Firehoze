require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

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

    should "return records" do
      assert_equal 1, Discount.list(@discount.sku, 1).size
    end

    fast_context "not referenced by line items" do
      should "allow delete" do
        assert @discount.can_delete?
      end
    end

    fast_context "referenced by line items" do
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
