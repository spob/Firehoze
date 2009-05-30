require 'test_helper'

class LineItemTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @line_item = Factory.create(:line_item)
    end

    should_validate_presence_of      :unit_price, :sku, :cart, :quantity
    should_allow_values_for          :unit_price, 0.99, 1, 1.23, 1000.2
    should_allow_values_for          :quantity, 1, 5
    should_not_allow_values_for      :unit_price, -2.12, 0, :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
    should_not_allow_values_for      :unit_price, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')
    should_not_allow_values_for      :quantity,0, -1, :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
    should_not_allow_values_for      :quantity,  2.12, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')

    should "calculate total price" do
      assert_equal 0.99, @line_item.full_price
    end
  end
end
