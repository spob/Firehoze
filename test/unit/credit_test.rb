require 'test_helper'

class CreditTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @credit = Factory.create(:credit)
    end

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
    end
  end
end
