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
    end

    should "strip white space from code" do
      @promotion.code = "  xxxx  "
      @promotion.save!
      assert_equal "xxxx", @promotion.code
    end
  end
end
