require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class PromotionTest < ActiveSupport::TestCase

  fast_context "given a promotion" do
    setup do
      @promotion = Factory.create(:promotion)
      assert @promotion.expires_at.present?
    end

    subject { @promotion }

    context "test attributes" do
      subject { @promotion }

      should_validate_presence_of :code, :promotion_type, :expires_at
      should_validate_uniqueness_of :code
      should_ensure_length_in_range :code, (0..15)
      should_ensure_length_in_range :promotion_type, (0..50)
      should_allow_values_for          :price, 0, 1, 22.23

      # Apparently should not allow values for only works if you pass the error message you expect
      # to see...though this is not clear in the shoulda documentation.
      should_not_allow_values_for      :price, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')
      should_not_allow_values_for      :price, -1,
                                       :message => I18n.translate('activerecord.errors.messages.greater_than_or_equal_to', :count => 0)
      should_allow_values_for          :credit_quantity, 1, 5

      should_not_allow_values_for      :credit_quantity, 0, -1,
                                       :message => I18n.translate('activerecord.errors.messages.greater_than',
                                                                  :count => 0)
      should_not_allow_values_for      :credit_quantity, 2.12, "a",
                                       :message => I18n.translate('activerecord.errors.messages.not_a_number')
    end

    fast_context "and a couple more records" do
      setup do
        Factory.create(:promotion)
        Factory.create(:promotion)
      end

      should "return rows" do
        assert_equal 3, Promotion.list(1, 10).size
      end
    end

    should "strip white space from code" do
      @promotion.code = "  xxxx  "
      @promotion.save!
      assert_equal "XXXX", @promotion.code
    end
  end
end
