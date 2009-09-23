require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class PaymentLevelTest < ActiveSupport::TestCase
  fast_context "given a payment level" do
    setup do
      @payment_level = Factory.create(:payment_level, :code => Time.now.to_i.to_s, :default_payment_level => true)
    end
    subject { @payment_level }
    
    should_have_many                 :users
    should_validate_presence_of      :rate, :name, :code
    should_validate_uniqueness_of    :name
    should_validate_uniqueness_of    :code
    should_allow_values_for          :rate, 0.99, 0.05, 0.01

    # Apparently should not allow values for only works if you pass the error message you expect
    # to see...though this is not clear in the shoulda documentation.
    should_not_allow_values_for      :rate, -2.12, 0, :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
    should_not_allow_values_for      :rate, 1, 2, :message => I18n.translate('activerecord.errors.messages.less_than', :count => 1)
    should_not_allow_values_for      :rate, "a", :message => I18n.translate('activerecord.errors.messages.not_a_number')

    fast_context "and creating a new default payment level" do
      setup do
        assert @payment_level.default_payment_level
        @new_payment_level = Factory.build(:payment_level, :name => 'new', :default_payment_level => true)
        assert @new_payment_level.default_payment_level
        assert @new_payment_level.save
        @payment_level = PaymentLevel.find(@payment_level.id)
        @new_payment_level = PaymentLevel.find(@new_payment_level.id)
      end

      should "reset default flag" do
        assert !@payment_level.default_payment_level
        assert @new_payment_level.default_payment_level
      end
    end

    fast_context "and creating a new non-default payment level" do
      setup do
        assert @payment_level.default_payment_level
        @new_payment_level = Factory.build(:payment_level, :name => 'new',
                                           :default_payment_level => false)
        assert !@new_payment_level.default_payment_level
        assert @new_payment_level.save!
        @payment_level = PaymentLevel.find(@payment_level.id)
        @new_payment_level = PaymentLevel.find(@new_payment_level.id)
      end

      should "not reset default flag" do
        assert @payment_level.default_payment_level
        assert !@new_payment_level.default_payment_level
      end
    end
  end
end
