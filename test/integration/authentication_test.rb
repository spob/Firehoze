require File.dirname(__FILE__) + '/../test_helper'

class AuthenticationTest < ActionController::IntegrationTest
  context "given a user" do
    setup do
      @user = Factory.create(:user)
    end

    should "login successfully" do
      visit login_url
      fill_in "user_session[login]", :with => @user.login
      fill_in "user_session[password]", :with => "xxxxx"
      click_button "Login"
      assert_contain "my firehoze"
    end
  end
end
