require 'test_helper'

class GiftCertificateTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @gift_certificate = Factory.create(:gift_certificate)
    end

    should_belong_to                 :user
    should_belong_to                 :gift_certificate_sku
    should_belong_to                 :line_item
    should_validate_presence_of      :user, :code, :credit_quantity, :line_item, :gift_certificate_sku 
    should_ensure_length_is          :code, 16

    # can't do should_validate_presence_of for discounted_unit_price because it's set implicitly'
    should_allow_values_for          :credit_quantity, 1, 5

    should_not_allow_values_for      :credit_quantity, 0, -1,
                                     :message => I18n.translate('activerecord.errors.messages.greater_than',
                                                                :count => 0)
    should_not_allow_values_for      :credit_quantity,  2.12, "a",
                                     :message => I18n.translate('activerecord.errors.messages.not_a_number')

    context "and testing the formatted code" do
      setup do
        @gift_certificate.code = "aaaabbbbccccdddd"
      end
      should "format the formatted_code" do
        assert_equal "aaaa-bbbb-cccc-dddd", @gift_certificate.formatted_code
      end
    end
  end
end