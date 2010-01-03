require File.dirname(__FILE__) + '/../test_helper'

class SearchTestTest < ActionController::IntegrationTest
  fixtures :all
  context "given a user" do
    setup do
      @user = Factory.create(:user)
    end

    context "Given some lessons" do
      setup do
        @lesson1 = Factory.create(:lesson, :title => "test1")
        @lesson2 = Factory.create(:lesson, :title => "test2")
        @lesson3 = Factory.create(:lesson, :title => "blah")
        @lesson1.update_attribute(:status, LESSON_STATUS_READY)
        @lesson2.update_attribute(:status, LESSON_STATUS_READY)
        @lesson3.update_attribute(:status, LESSON_STATUS_READY)
        assert @lesson1.ready?
      end

      should "find lessons with normal search" do
        visit login_url
        fill_in "user_session[login]", :with => @user.login
        fill_in "user_session[password]", :with => "xxxxx"
        click_button "Login"
        assert_contain "my firehoze"
        fill_in "search_criteria", :with => "test"
        click_button 'searchbox_submit'
        assert_contain "Search Results"
        assert_contain "no results"
      end

      should "find lessons with advanced search" do
        visit advanced_search_lessons_path
        fill_in "advanced_search_title", :with => 'blah'
        click_button 'advanced_search_submit'
        assert_contain "Advanced Lesson Search"
        assert_contain "no results"
      end
    end
  end
end
