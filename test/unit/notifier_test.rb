require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class NotifierTest < ActiveSupport::TestCase
  fast_context "given a payment" do
    setup do
      @payment = Factory.create(:payment)
    end

    should "not fail when sending notification" do
      assert_nothing_raised do
        Notifier.deliver_payment_notification(@payment.id)
      end
    end
  end

  fast_context "given an existing order" do
    setup { @order = Factory.create(:completed_order) }

    should "not fail when sending notification" do
      assert_not_nil @order
      assert @order.id > 0
      assert_nothing_raised do
        Notifier.deliver_receipt_for_order(@order)
      end
    end
  end

  fast_context "given an gift certificate" do
    setup { @gift_certificate = Factory.create(:gift_certificate) }

    should "not fail when sending notification" do
      assert_nothing_raised do
        Notifier.deliver_gift_certificate_received(@gift_certificate, @gift_certificate.user)
      end
    end
  end

  fast_context "test contact user" do
    setup do
      @user1 = Factory.create(:user)
      @user2 = Factory.create(:user)
    end

    should "not fail when sending notification" do
      assert_nothing_raised do
        Notifier.deliver_contact_user(@user1, @user2, "some subject", "this is a message")
      end
    end
  end

  fast_context "with some admins defined" do
    setup do
      @user = Factory.create(:user)
      @user.has_role 'admin'
    end

    fast_context "given a video" do
      setup { @video = Factory.create(:full_processed_video) }

      should "not fail when sending notification" do
        assert_nothing_raised do
          Notifier.deliver_lesson_processing_failed(@video)
        end
      end
    end

    fast_context "given a lesson" do
      setup { @lesson = Factory.create(:lesson) }

      should "not fail when sending notification" do
        assert_nothing_raised do
          Notifier.deliver_lesson_processing_hung(@lesson)
        end
      end
    end
  end
end
