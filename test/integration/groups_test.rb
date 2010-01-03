require File.dirname(__FILE__) + '/../test_helper'

class GroupsTest < ActionController::IntegrationTest
  context "given a user" do
    setup do
      @user = Factory.create(:user)
      @user.has_role('admin')
    end

    context "with some groups" do
      setup do
        @group1 = Factory.create(:group)
        @group2 = Factory.create(:group)
        @group3 = Factory.create(:group)
        @group4 = Factory.create(:group)
      end

      context "and logs in" do

        context "and some categories" do
          setup do
            @category1 = Factory.create(:category, :parent_category => nil)
            @category1a = Factory.create(:category, :parent_category => @category1)
            @category1b = Factory.create(:category, :parent_category => @category1)
            @category2 = Factory.create(:category, :parent_category => nil)
            @category2a = Factory.create(:category, :parent_category => @category2)
            @category2b = Factory.create(:category, :parent_category => @category2)
          end

          should "browse groups by category" do
            visit login_url
            fill_in "user_session[login]", :with => @user.login
            fill_in "user_session[password]", :with => "xxxxx"
            click_button "Login"
            assert_contain "my firehoze"
            visit groups_path
            assert_contain @category1.name
            assert_contain @category1a.name
            assert_contain @category1b.name
            assert_contain @category2.name
            assert_contain @category2a.name
            assert_contain @category2b.name
            click_link @category1.name
            assert_contain @category1.name
            assert_contain @category1a.name
            assert_contain @category1b.name
            assert_contain @category2.name
            assert_not_contain @category2a.name
            assert_not_contain @category2b.name
          end
        end

        should "visit list admin page" do
          visit login_url
          fill_in "user_session[login]", :with => @user.login
          fill_in "user_session[password]", :with => "xxxxx"
          click_button "Login"
          assert_contain "my firehoze"
          visit list_admin_groups_url
          assert_contain @group1.name
          assert_contain @group2.name
          assert_contain @group3.name
          assert_contain @group4.name
          click_link @group2.name
          assert_contain 'Alas'
          click_link 'on me'
          assert_contain 'Alas'
          click_link 'by me'
          assert_contain 'Alas'
#        save_and_open_page
        end
      end
    end
  end
end