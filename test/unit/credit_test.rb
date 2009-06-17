require 'test_helper'

class CreditTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup { @credit = Factory.create(:credit) }

    should_validate_presence_of      :price, :acquired_at, :price
    should_allow_values_for          :price, 0, 1, 22.23

    # Apparently should not allow values for only works if you pass the error message you expect
    # to see...though this is not clear in the shoulda documentation.
    should_not_allow_values_for      :price, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')
    should_not_allow_values_for      :price, -1,
                                     :message => I18n.translate('activerecord.errors.messages.greater_than_or_equal_to', :count => 0)
    should_belong_to :user, :lesson
    should_belong_to :sku

    context "that has not yet been redeemed" do
      setup { @credit.update_attribute(:redeemed_at, nil) }

      should "retrieve available rows" do
        assert_equal 1, Credit.available.count
      end

      should "retrieve rows for which a warning hasn't been issues" do
        assert_equal 1, Credit.unwarned.count
      end

      context "but has been warned" do
        setup { Credit.update_all(:expiration_warning_issued_at => Time.zone.now)}

        should "retrieve return no rows" do
          assert_equal 0, Credit.unwarned.count
        end
      end
    end

    context "and a second record ready to be expired" do
      setup do
        @credit.update_attribute(:redeemed_at, nil)
        @credit2 = Factory.create(:credit, :redeemed_at => nil)
        @credit2.update_attribute(:will_expire_at, 1.days.ago)
      end   

      should "have two credits" do
        assert_equal 2, Credit.available.count
      end

      should "have one credit about to expire" do
        assert_equal 1, Credit.available.to_expire(Time.zone.now).unwarned.count
      end

      context "after invoking expire_unused_credits" do
        setup do
          Credit.expire_unused_credits
        end

        should "have no credit about to expire" do
          assert Credit.available.to_expire(Time.zone.now).empty?
        end
      end
    end
  end

  context "given multiple records some of which should be warned" do
    setup do
      @warning_days = APP_CONFIG['warn_before_credit_expiration_days'].to_i
      # should not get warning since this is redeemed
      @credit1 = Factory.create(:credit)
      # should not get warning since this is warned already
      @credit2 = Factory.create(:credit, :redeemed_at => nil, :expiration_warning_issued_at => 10.days.ago)
      # should not get warning since it has not yet entered the warning period
      @credit3 = Factory.create(:credit, :redeemed_at => nil)
      # this should get warned
      @credit4 = Factory.create(:credit, :redeemed_at => nil)
      # this should get warned
      @credit5 = Factory.create(:credit, :redeemed_at => nil)
      
      # must set will_expire_at separately since it's set by a callback
      @credit1.update_attribute(:will_expire_at, 2.days.since)
      @credit2.update_attribute(:will_expire_at, 2.days.since)
      @credit3.update_attribute(:will_expire_at, (@warning_days + 1).days.since)
      @credit4.update_attribute(:will_expire_at, (@warning_days - 1).days.since)
      @credit5.update_attribute(:will_expire_at, (@warning_days - 2).days.since)

      # Okay, process the sucker
      Credit.expire_unused_credits

      # Refresh from the database
      @credit1 = Credit.find(@credit1.id)
      @credit2 = Credit.find(@credit2.id)
      @credit3 = Credit.find(@credit3.id)
      @credit4 = Credit.find(@credit4.id)
      @credit5 = Credit.find(@credit5.id)
      assert_nil @credit4.redeemed_at
      assert_nil @credit5.redeemed_at
      assert_nil @credit4.expired_at
      assert_nil @credit5.expired_at
      assert @credit4.will_expire_at < @warning_days.days.since
      assert @credit5.will_expire_at < @warning_days.days.since
    end

    should "set warning sent flag" do
      assert_nil @credit1.expiration_warning_issued_at
      assert_not_nil @credit2.expiration_warning_issued_at
      assert @credit2.expiration_warning_issued_at < 1.days.ago
      assert_nil @credit3.expiration_warning_issued_at
      assert_not_nil @credit4.expiration_warning_issued_at
      assert_not_nil @credit5.expiration_warning_issued_at
    end
  end
end
