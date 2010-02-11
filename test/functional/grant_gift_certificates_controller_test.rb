require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class GrantGiftCertificatesControllerTest < ActionController::TestCase

  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "on GET to :new" do
      setup { get :new }

      should_not_assign_to :gift_certificate
      should_respond_with :redirect
      should_set_the_flash_to /denied/
      should_redirect_to("Lesson index") { lessons_url }
    end

    fast_context "as a payment mgr" do
      setup { @user.is_paymentmgr }

      fast_context "on GET to :new" do
        setup { get :new }

        should_assign_to :gift_certificate
        should_respond_with :success
        should_not_set_the_flash
        should_render_template 'new'
      end


      context "with a gift cert sku" do
        setup do
          GiftCertificateSku.create(:sku => 'GIFT_CERTIFICATE_SKU',
                                    :description => "This is a longer description",
                                    :num_credits => 6,
                                    :price => 0.99)
          assert !GiftCertificateSku.find_by_sku(GIFT_CERTIFICATE_SKU).nil?
        end

        context "on POST to :create" do
          setup do
            @recipient = Factory(:user)
            post :create, :gift_certificate => { :quantity_to_grant => "2", :price => "0.45", :credit_quantity => 6, :to_user => @recipient.login }
          end

          should_assign_to :gift_certificate
          should_respond_with :redirect
          should_set_the_flash_to /created/
          should "create a gift certificate" do
            @gift = GiftCertificate.find(assigns(:gift_certificate))
            assert_equal 6, @gift.credit_quantity
            assert_equal @recipient, @gift.user
            assert_equal 0.45, @gift.price
            assert_nil @gift.line_item
          end
          should_redirect_to("Gift Certificates list_admin") { list_admin_gift_certificates_url }
        end
      end
    end
  end
end
