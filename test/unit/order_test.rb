require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup { @order = Factory.create(:order) }

    should_belong_to :user
    should_belong_to :cart
    should_have_many :transactions
    should_validate_presence_of :user, :cart, :ip_address, :user, :address1,
                                :city, :state, :country, :zip, :billing_name
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
  end
end