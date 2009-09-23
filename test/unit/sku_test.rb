require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class SkuTest < ActiveSupport::TestCase
  fast_context "given an existing record" do
    setup do
      @sku = Factory.create(:credit_sku)
    end
    subject { @sku }

    should_have_many                 :line_items
    should_validate_uniqueness_of    :sku
    should_validate_presence_of      :sku, :type, :description
    should_allow_values_for          :sku, "123456789012345678901234567890"
    should_allow_values_for          :description, "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"

    # Apparently should not allow values for only works if you pass the error message you expect
    # to see...though this is not clear in the shoulda documentation.
    should_not_allow_values_for      :sku, "1234567890123456789012345678901", :message => I18n.translate('activerecord.errors.messages.too_long', :count => 30)
    should_not_allow_values_for      :description,
            "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890x",
            :message => I18n.translate('activerecord.errors.messages.too_long', :count => 150)
    should_allow_values_for          :sku, "a", "sku123"

    fast_context "and a couple more records" do
      setup do
        Factory.create(:credit_sku)
        Factory.create(:credit_sku)
      end

      should "return rows" do
        assert_equal 3, Sku.list(1, 10).size
      end
    end

    fast_context "and a non-admin user" do
      setup { @user = Factory(:user) }

      should "not be able to delete or edit" do
        assert !@sku.can_edit?(@user)
        assert !@sku.can_delete?(@user)
      end

      fast_context "with admin access" do
        setup { @user.has_role 'admin' }

        should "be able to delete or edit" do
          assert @sku.can_edit?(@user)
          assert @sku.can_delete?(@user)
        end
      end
    end
  end
end
