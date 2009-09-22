require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class PaymentTest < ActiveSupport::TestCase
  fast_context "given a payment" do
    setup  { @payment = Factory.create(:payment) }

    should_belong_to :user
    should_have_many :credits
    should_validate_presence_of :user, :amount
    should_allow_values_for          :amount, 5.99, 0.05, 9999.3

    # Apparently should not allow values for only works if you pass the error message you expect
    # to see...though this is not clear in the shoulda documentation.
    should_not_allow_values_for      :amount, -2.12, 0, :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
  end
end