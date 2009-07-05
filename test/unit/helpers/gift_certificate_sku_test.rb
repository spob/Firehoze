require 'test_helper'

class GiftCertificateSkuTest < ActiveSupport::TestCase
  context "give a sku for a gift certificate" do
    setup do
      @sku = Factory.create(:gift_certificate_sku, :price => 9, :num_credits => 10)
    end

    should_have_many :gift_certificates

    context "when executing an order for the sku" do
      setup { @user = Factory.create(:user) }

      should "create a gift certificate" do
        assert_equal 0, @user.gift_certificates.size
        @sku.execute_order_line(@user, @sku.num_credits)
        @user = User.find(@user.id)
        assert_equal 1, @user.gift_certificates.size
      end
    end
  end
end