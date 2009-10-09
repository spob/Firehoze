require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class GiftCertificateTest < ActiveSupport::TestCase
  fast_context "given an gift certificate" do
    setup{ @gift_certificate = Factory.create(:gift_certificate) }
    subject { @gift_certificate }

    should_belong_to                 :user
    should_belong_to                 :gift_certificate_sku
    should_belong_to                 :line_item
    should_belong_to                 :redeemed_by_user
    should_validate_presence_of      :user, :code, :credit_quantity, :gift_certificate_sku
    should_ensure_length_is          :code, 16

    # can't do should_validate_presence_of for discounted_unit_price because it's set implicitly'
    should_allow_values_for          :credit_quantity, 1, 5

    should_not_allow_values_for      :credit_quantity, 0, -1,
                                     :message => I18n.translate('activerecord.errors.messages.greater_than',
                                                                :count => 0)
    should_not_allow_values_for      :credit_quantity,  2.12, "a",
                                     :message => I18n.translate('activerecord.errors.messages.not_a_number')

    fast_context ", testing the formatted code" do
      setup do
        @gift_certificate.code = "aaaabbbbccccdddd"
      end
      should "format the formatted_code" do
        assert_equal "aaaa-bbbb-cccc-dddd", @gift_certificate.formatted_code
      end

      fast_context "and giving the gift certificate to another user" do
        setup do
          @old_user = @gift_certificate.user
          @new_user = Factory.create(:user)
          assert !(@old_user == @new_user)
          @comments = "Given to user #{@new_user.login}"
          assert !(@comments == @gift_certificate.comments)
          @gift_certificate.give(@new_user, @comments)
        end

        should "have been given to new user" do
          assert_equal @new_user, @gift_certificate.user
          assert_equal @comments, @gift_certificate.comments
        end
      end
    end

    fast_context "and a couple more, some redeemed" do
      setup do
        @gift_certificate2 = Factory.create(:gift_certificate)
        @gift_certificate3 = Factory.create(:redeemed_gift_certificate)
        @gift_certificate4 = Factory.create(:gift_certificate)
        @gift_certificate4.update_attribute(:expires_at, 1.days.ago)
      end

      should "retrieve un-redeemed gift certificates" do
        certs = GiftCertificate.active
        assert_equal 2, certs.size
        assert certs.include?(@gift_certificate)
        assert certs.include?(@gift_certificate2)
        assert !certs.include?(@gift_certificate3)
        assert !certs.include?(@gift_certificate4)
      end

      fast_context "invoking the list method" do
        setup { @gifts = GiftCertificate.list(1, @gift_certificate2.user) }

        should "return 1 lessons" do
          assert_equal 1, @gifts.size
        end

        fast_context "as an admin user" do
          setup do
            @gift_certificate2.user.has_role 'admin'
            @gifts = GiftCertificate.list(1, @gift_certificate2.user)
          end

          should "return 3 lessons" do
            assert_equal 3, @gifts.size
          end
        end
      end
    end

    fast_context "on redeem" do
      setup { assert @gift_certificate.user.credits.available.empty? }

      should "redeem increase credits" do
        @gift_certificate.redeem(@gift_certificate.user)
        assert_equal 5, @gift_certificate.user.credits.available.size
        assert !@gift_certificate.redeemed_at.nil?
        assert_equal @gift_certificate.user, @gift_certificate.user.credits.first.user
      end
    end
  end
end