require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup { @order = Factory.create(:order) }

    should_belong_to :user
    should_belong_to :cart
    should_have_many :transactions
    should_have_many :last_transaction
    should_validate_presence_of :user, :cart, :ip_address, :user, :address1,
                                :city, :state, :country, :zip, :billing_name,
                                :card_type, :card_expires_on
    should_ensure_length_in_range    :last_name, (0..50)
    should_ensure_length_in_range    :first_name, (0..50)
    should_ensure_length_in_range    :billing_name, (0..100)
    should_ensure_length_in_range    :address1, (0..150)
    should_ensure_length_in_range    :address2, (0..150)
    should_ensure_length_in_range    :city, (0..50)
    should_ensure_length_in_range    :state, (0..50)
    should_ensure_length_in_range    :country, (0..50)
    should_ensure_length_in_range    :zip, (0..25)

    should "be a valid order" do
      # Since the test environment users a bogus gateway, this really doesn't do
      # real validation
      assert @order.valid?
    end

    should "format the billing address" do
      assert_equal "123 Main St.\nNew York, NY 10001\nUS", @order.formatted_billing_address
      assert_equal "123 Main St.<br/>New York, NY 10001<br/>US", @order.formatted_billing_address("<br/>")
    end

    context "with a billing address with address 2 populated" do
      setup { @order.address2 = "Apartment 2A" }

      should "format the billing address" do
        assert_equal "123 Main St.\nApartment 2A\nNew York, NY 10001\nUS", @order.formatted_billing_address
        assert_equal "123 Main St.<br/>Apartment 2A<br/>New York, NY 10001<br/>US", @order.formatted_billing_address("<br/>")
      end
    end

    context "with a valid credit card number" do
      setup do
        # a value of 1 in the credit_card signals to the bogus gateway to successfully process the transaction
        @order.card_number = "1"
      end

      should "create a transaction record" do
        assert @order.purchase
        assert !@order.transactions.empty?
      end
    end
  end

  should "retrieve user friendly card type" do
    assert_equal "American Express", Order.user_friend_card_type("american_express")
    assert_nil Order.user_friend_card_type("xxx")
  end
end