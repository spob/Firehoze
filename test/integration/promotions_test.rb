require File.dirname(__FILE__) + '/../test_helper'

class PromotionsTest < ActionController::IntegrationTest
  context "given a user" do
    setup do
      @user = Factory.create(:user)
      @user.has_role(ROLE_PAYMENT_MGR)
    end

    context "with some promotions" do
      setup do
        @promo1 = Factory.create(:promotion)
        @promo2 = Factory.create(:promotion)
        @promo3 = Factory.create(:promotion)
        @promo4 = Factory.create(:promotion)
      end

      context "and logs in" do

        should "visit pages" do
          visit login_url
          fill_in "user_session[login]", :with => @user.login
          fill_in "user_session[password]", :with => "xxxxx"
          click_button "Login"
          assert_contain "my firehoze"
          visit promotions_path
          assert_contain @promo1.code
          assert_contain @promo2.code
          assert_contain @promo3.code
          assert_contain @promo4.code

          click_link 'New Promotion'
          fill_in "promotion[code]", :with => "xxxx"
          fill_in "promotion[price]", :with => "0.25"
          fill_in "promotion[credit_quantity]", :with => "23"
          fill_in "promotion[description]", :with => "blah blah blah"
          click_button "Create"
          assert_contain "XXXX"
          assert_contain "$0.25"
          assert_contain "blah"
          assert_contain "23"
        end
      end
    end
  end
end
