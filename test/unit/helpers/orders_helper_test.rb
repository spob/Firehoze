require File.dirname(__FILE__) + '/../../test_helper'

class OrdersHelperTest < ActionView::TestCase
  context "with an existing order" do
    setup { @order = Factory.create(:order) }

    should "format the billing address" do
      assert_equal "123 Main St.\nNew York, NY 10001\nUnited States", order_formatted_address(@order)
      assert_equal "123 Main St.<br/>New York, NY 10001<br/>United States", order_formatted_address(@order, "<br/>")
    end

    context "with a billing address with address 2 populated" do
      setup { @order.address2 = "Apartment 2A" }

      should "format the billing address" do
        assert_equal "123 Main St.\nApartment 2A\nNew York, NY 10001\nUnited States", order_formatted_address(@order)
        assert_equal "123 Main St.<br/>Apartment 2A<br/>New York, NY 10001<br/>United States", order_formatted_address(@order, "<br/>")
      end
    end
  end
end
