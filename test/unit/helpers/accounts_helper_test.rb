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

  context "testing instructor_wizard_breadcrumbs" do
    setup do
      @user = Factory.create(:user)
    end

    should "calculate the text" do
      assert "<li>Instructor Agreement</li>\n<li>Exclusivity</li>\n<li>Postal Address</li>\n<li>Confirm Contact Information</li>\n<li>Tax Witholding</li>",
             instructor_wizard_breadcrumbs(1)
    end
  end
end
