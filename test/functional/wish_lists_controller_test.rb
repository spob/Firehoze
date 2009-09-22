require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class WishListsControllerTest < ActionController::TestCase
  fast_context "with an existing lesson" do
    setup { @lesson = Factory.create(:lesson) }

    fast_context "and when logged on" do
      setup do
        activate_authlogic
        @user = Factory(:user)
        UserSession.create(@user)
      end

      fast_context "on POST to :create" do
        setup do
          post :create, :id => @lesson
        end

        should_assign_to :lesson
        should_respond_with :redirect
        should_set_the_flash_to "Lesson added to your wish list"
        should_redirect_to("show lesson page") { lesson_url(@lesson) }

        should "wishes for the lesson" do
          assert @user.on_wish_list?(@lesson)
        end
      end

      fast_context "on POST to :create when already owned" do
        setup do
          @user.credits.create!(:price => 0.99, :lesson => @lesson, :acquired_at => Time.now,
                                :line_item => Factory.create(:line_item))
          assert @user.owns_lesson?(@lesson)
          post :create, :id => @lesson
        end

        should_assign_to :lesson
        should_respond_with :redirect
        should_set_the_flash_to /You already own/
        should_redirect_to("show lesson page") { lesson_url(@lesson) }

        should "does not wish for the lesson" do
          assert !@user.on_wish_list?(@lesson)
        end
      end

      fast_context "on POST to :create when you are the author" do
        setup do
          @lesson2 = Factory.create(:lesson, :instructor => @user)
          assert @lesson2.instructor == @user
          post :create, :id => @lesson2
        end

        should_assign_to :lesson
        should_respond_with :redirect
        should_set_the_flash_to /As the instructor of this lesson/
        should_redirect_to("show lesson page") { lesson_url(@lesson2) }

        should "does not wish for the lesson" do
          assert !@user.on_wish_list?(@lesson2)
        end
      end

      fast_context "on POST to :create when already on the wish list" do
        setup do
          @user.wishes << @lesson
          assert @user.on_wish_list?(@lesson)
          post :create, :id => @lesson
        end

        should_assign_to :lesson
        should_respond_with :redirect
        should_set_the_flash_to /lesson is already on your wish list/
        should_redirect_to("show lesson page") { lesson_url(@lesson) }

        should "does not wish for the lesson" do
          assert @user.on_wish_list?(@lesson)
        end
      end

      fast_context "on DELETE to :destroy" do
        setup do
          @user.wishes << @lesson
          assert @user.on_wish_list?(@lesson)
          delete :destroy, :id => @lesson
        end

        should_set_the_flash_to /Lesson has been removed/
        should_respond_with :redirect
        should_redirect_to("show lesson page") { lesson_url(@lesson) }

        should "not wish for the lesson" do
          assert !@user.on_wish_list?(@lesson)
        end
      end

      fast_context "on DELETE to :destroy when not on the wait list already" do
        setup do
          assert !@user.on_wish_list?(@lesson)
          delete :destroy, :id => @lesson
        end

        should_set_the_flash_to "This lesson is not on your wishlist"
        should_respond_with :redirect
        should_redirect_to("show lesson page") { lesson_url(@lesson) }

        should "not wish for the lesson" do
          assert !@user.on_wish_list?(@lesson)
        end
      end
    end
  end
end
