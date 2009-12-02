require File.dirname(__FILE__) + '/../test_helper'

class MyFirehozeTest < ActionController::IntegrationTest
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
      assert_contain "Recent Activity"
      assert_contain "Alas, no activity to report"
      assert_contain "Latest Tweets"
      click_link "by me"
      click_link "on me"
      click_link "by instructors I'm following"
      
      click_link "My Stuff"
      assert_contain "Lessons"
      assert_contain "Recently Browsed"
      click_link "Owned"
      assert_contain "You have not purchased any lessons"
      click_link "Wishlist"
      assert_contain "You haven't added any lessons to your wish list"

      click_link "Reviews"
      assert_contain "You haven't reviewed any lessons"


      click_link "Groups"
      assert_contain "You do not belong to any groups"

      click_link "Followed Instructors"

      click_link "Account History"
      assert_contain "Orders"
      assert_contain "You have not placed any orders"

      assert_contain "Credits"
      assert_contain "You have no available credits"
      assert_contain "You have not yet redeemed any credits"
      assert_contain "you don't have any credits that have expired"
    end
  end
end
