require File.dirname(__FILE__) + '/../../test_helper'

class AccountsHelperTest < ActionView::TestCase
  context "testing formatted_address" do
    setup do
      @user = Factory.build(:user, :address1 => "135 Larch Row", :city => "Wenham",
                            :state => "MA", :postal_code => "01944", :country => "US")
    end

    should "format address" do
      assert_equal "135 Larch Row\nWenham, MA 01944\nUnited States",
                   formatted_address
    end
  end
end
