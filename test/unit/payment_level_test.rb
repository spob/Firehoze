require File.dirname(__FILE__) + '/../test_helper'

class PaymentLevelTest < ActiveSupport::TestCase
  context "given a payment level" do
    setup do
      @payment_level = Factory.create(:payment_level)
    end

    should_validate_presence_of      :rate, :name
    should_allow_values_for          :rate, 0.99, 0.05, 0.01

    # Apparently should not allow values for only works if you pass the error message you expect
    # to see...though this is not clear in the shoulda documentation.
    should_not_allow_values_for      :rate, -2.12, 0, :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
    should_not_allow_values_for      :rate, 1, 2, :message => I18n.translate('activerecord.errors.messages.less_than', :count => 1)
    should_not_allow_values_for      :rate, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')
  end
end
