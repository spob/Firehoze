require 'test_helper'

class SkuTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @sku = Factory.create(:credit_sku)
    end

    should_have_many                 :line_items
    should_validate_uniqueness_of    :sku
    should_validate_presence_of      :sku, :type, :description
    should_allow_values_for          :sku, "123456789012345678901234567890"
    should_allow_values_for          :description, "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
    should_not_allow_values_for      :sku, "1234567890123456789012345678901", :message => I18n.translate('activerecord.errors.messages.too_long', :count => 30)

    should_not_allow_values_for      :description,
            "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890x",
            :message => I18n.translate('activerecord.errors.messages.too_long', :count => 150)
    should_allow_values_for          :sku, "a", "sku123"

    context "and a couple more records" do
      setup do
        Factory.create(:credit_sku)
        Factory.create(:credit_sku)
      end

      should "return rows" do
        assert_equal 3, Sku.list(1).size
      end
    end

    context "and a non-sysadmin user" do
      setup { @user = Factory(:user) }

      should "not be able to delete or edit" do
        assert !@sku.can_edit?(@user)
        assert !@sku.can_delete?(@user)
      end

      context "with sysadmin access" do
        setup { @user.has_role 'sysadmin' }

        should "be able to delete or edit" do
          assert @sku.can_edit?(@user)
          assert @sku.can_delete?(@user)
        end
      end
    end
  end
end
