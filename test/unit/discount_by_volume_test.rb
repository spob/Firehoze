require 'test_helper'

class DiscountByVolumeTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @discount = Factory.create(:discount_by_volume)
    end

    should_validate_presence_of      :minimum_quantity, :percent_discount
    should_allow_values_for          :percent_discount, 0.99, 0.05, 1
    should_allow_values_for          :minimum_quantity, 1, 5

    should_not_allow_values_for      :percent_discount, -2.12, 0, :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
    should_not_allow_values_for      :percent_discount, 1.1, 2, :message => I18n.translate('activerecord.errors.messages.less_than_or_equal_to', :count => 1)
    should_not_allow_values_for      :percent_discount, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')

    should_not_allow_values_for      :minimum_quantity,0, -1, :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
    should_not_allow_values_for      :minimum_quantity,  2.12, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')
  end

  context "given a range of discounts" do
    setup do
      @discount5 = Factory.create(:discount_by_volume, :minimum_quantity => 5, :percent_discount => 0.05)
      @discount10 = Factory.create(:discount_by_volume, :minimum_quantity => 10, :percent_discount => 0.10)
      @discount20 = Factory.create(:discount_by_volume, :minimum_quantity => 20, :percent_discount => 0.20)
    end

    should "return no discount for quantities below 5" do
      assert_nil DiscountByVolume.max_discount_by_volume(1).first
      assert_nil DiscountByVolume.max_discount_by_volume(2).first
      assert_nil DiscountByVolume.max_discount_by_volume(3).first
      assert_nil DiscountByVolume.max_discount_by_volume(4).first
    end

    should "return 5% for quantities above or equal to 5 and below 10" do
      assert_equal 0.05, DiscountByVolume.max_discount_by_volume(5).first.percent_discount
      assert_equal 0.05, DiscountByVolume.max_discount_by_volume(6).first.percent_discount
      assert_equal 0.05, DiscountByVolume.max_discount_by_volume(7).first.percent_discount
      assert_equal 0.05, DiscountByVolume.max_discount_by_volume(8).first.percent_discount
      assert_equal 0.05, DiscountByVolume.max_discount_by_volume(9).first.percent_discount
    end

    should "return 10% for quantities above or equal to 10 and below 20" do
      assert_equal 0.10, DiscountByVolume.max_discount_by_volume(10).first.percent_discount
      assert_equal 0.10, DiscountByVolume.max_discount_by_volume(13).first.percent_discount
      assert_equal 0.10, DiscountByVolume.max_discount_by_volume(16).first.percent_discount
      assert_equal 0.10, DiscountByVolume.max_discount_by_volume(19).first.percent_discount
    end

    should "return 20% for quantities above 10" do
      assert_equal 0.20, DiscountByVolume.max_discount_by_volume(20).first.percent_discount
      assert_equal 0.20, DiscountByVolume.max_discount_by_volume(21).first.percent_discount
      assert_equal 0.20, DiscountByVolume.max_discount_by_volume(1000).first.percent_discount
      assert_equal 0.20, DiscountByVolume.max_discount_by_volume(20000).first.percent_discount
    end
  end
end
