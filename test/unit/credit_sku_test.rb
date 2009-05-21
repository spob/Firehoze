require 'test_helper'

class CreditSkuTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @sku = Factory.create(:credit_sku)
    end

    should_validate_presence_of      :price, :num_credits
    should_allow_values_for          :price, 0, 1, 22.23
    should_allow_values_for          :num_credits, 1, 2, 3
    should_not_allow_values_for      :price, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')
    should_not_allow_values_for      :price, -1,
            :message => I18n.translate('activerecord.errors.messages.greater_than_or_equal_to', :count => 0)
    should_not_allow_values_for      :num_credits, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')
    should_not_allow_values_for      :num_credits, -1, 0,
            :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
    should_have_many :credits
  end
end
