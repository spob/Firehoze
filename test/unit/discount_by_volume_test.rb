require 'test_helper'

class DiscountByVolumeTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @discount = Factory.create(:discount_by_volume)
    end

    should_validate_presence_of      :minimum_quantity, :percent_discount
    should_allow_values_for          :percent_discount, 0.99, 1, 1.23, 1000.2
    should_allow_values_for          :minimum_quantity, 1, 5

    should_not_allow_values_for      :percent_discount, -2.12, 0, :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
    should_not_allow_values_for      :percent_discount, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')

    should_not_allow_values_for      :minimum_quantity,0, -1, :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
    should_not_allow_values_for      :minimum_quantity,  2.12, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')
  end
end
