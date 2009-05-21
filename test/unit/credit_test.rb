require 'test_helper'

class CreditTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @credit = Factory.create(:credit)
    end

    should_validate_presence_of      :price, :sku, :acquired_at, :price
    should_allow_values_for          :price, 0, 1, 22.23
    should_not_allow_values_for      :price, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')
    should_not_allow_values_for      :price, -1,
            :message => I18n.translate('activerecord.errors.messages.greater_than_or_equal_to', :count => 0)
    should_belong_to :user, :video
    should_belong_to :sku
  end
end
