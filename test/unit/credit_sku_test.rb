require 'test_helper'

class CreditSkuTest < ActiveSupport::TestCase
  context "give a sku for multiple credits" do
    setup do
      @sku = Factory.create(:credit_sku, :price => 9, :num_credits => 10)
    end

    context "when executing an order for the sku" do
      setup { @user = Factory.create(:user) }

      should "generates credits for the user" do
        assert_equal 0, @user.credits.size
        @sku.execute_order(@user)
        @user = User.find(@user.id)
        assert_equal 10, @user.credits.size
      end
    end
  end

  context "given an existing record" do
    setup { Factory.create(:credit_sku) }

    should_validate_presence_of      :price, :num_credits
    should_allow_values_for          :price, 0, 1, 22.23
    should_allow_values_for          :num_credits, 1, 2, 3
    should_not_allow_values_for      :price, "a",
            :message => I18n.translate('activerecord.errors.messages.not_a_number')
    should_not_allow_values_for      :price, -1,
            :message => I18n.translate('activerecord.errors.messages.greater_than_or_equal_to', :count => 0)
    should_not_allow_values_for      :num_credits, "a",
            :message => I18n.translate('activerecord.errors.messages.not_a_number')
    should_not_allow_values_for      :num_credits, -1, 0,
            :message => I18n.translate('activerecord.errors.messages.greater_than', :count => 0)
    should_have_many :credits
  end
end