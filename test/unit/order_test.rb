require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class OrderTest < ActiveSupport::TestCase
  context "given an existing order" do
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

    fast_context "with a valid credit card number" do
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

  fast_context "email order receipt" do
    setup do
      assert PeriodicJob.all.empty?
      Factory.create(:order).email_receipt
    end

    should "have a periodic job" do
      assert 1, PeriodicJob.all.size
    end
  end
end