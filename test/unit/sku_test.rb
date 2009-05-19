require 'test_helper'

class SkuTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @sku = Factory.create(:credit_sku)
    end

    should_validate_uniqueness_of    :sku
    should_validate_presence_of      :sku, :type, :description
    should_allow_values_for          :sku, "123456789012345678901234567890"
    should_allow_values_for          :description, "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
    should_not_allow_values_for      :sku, "1234567890123456789012345678901", :message => I18n.translate('activerecord.errors.messages.too_long', :count => 30)

    should_not_allow_values_for      :description,
            "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890x",
            :message => I18n.translate('activerecord.errors.messages.too_long', :count => 150)
    should_allow_values_for          :sku, "a", "sku123"
  end
end
