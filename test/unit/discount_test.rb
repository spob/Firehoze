require 'test_helper'

class DiscountTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @discount = Factory.create(:discount_by_volume)
    end

    should_validate_presence_of      :sku
  end
end
