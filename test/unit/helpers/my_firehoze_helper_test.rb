require File.dirname(__FILE__) + '/../../test_helper'
require 'fast_context'

class MyFirehozeHelperTest < ActionView::TestCase
  context "when logged on" do
    setup do
      activate_authlogic
      @active_user = Factory(:user)
      UserSession.create @active_user
    end

    fast_context "given an instructor with lessons" do
      setup do
        @user = Factory.create(:user)
        @lesson1 = Factory.create(:lesson, :instructor => @active_user)
        @lesson2 = Factory.create(:lesson, :instructor => @active_user)
        @lesson3 = Factory.create(:lesson, :instructor => @active_user)
        @lesson4 = Factory.create(:lesson, :instructor => @active_user)
        @credit1 = Factory.create(:credit, :lesson => @lesson1, :user => @user)
        @credit2 = Factory.create(:credit, :lesson => @lesson2, :user => @user)
        @credit3 = Factory.create(:credit, :lesson => @lesson3, :user => @user)
      end

      fast_context "test concatenate_lessons" do
        should "concatenate lessons string" do
          assert_equal "#{link_to(@lesson1.title, lesson_path(@lesson1))}, #{link_to(@lesson2.title, lesson_path(@lesson2))}, #{link_to(@lesson3.title, lesson_path(@lesson3))}",
                       list_instructed_lessons(@user, @active_user)
          assert_equal "", list_instructed_lessons(@user, Factory.create(:user))
        end
      end
    end
  end
end
