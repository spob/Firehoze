require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class AcquireLessonsControllerTest < ActionController::TestCase

  fast_context "when logged in" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user
    end

    fast_context "with a lesson" do
      setup { @lesson = Factory.create(:lesson) }

      context "on GET to :new" do
        setup { get :new, :id => @lesson }

        should_assign_to :lesson
        should_respond_with :success
        should_not_set_the_flash
        should_render_template "new"
      end

      fast_context "and no available credits" do
        setup { post :create, :id => @lesson }

        should_set_the_flash_to I18n.t('lesson.need_credits')
        should_redirect_to("online store") { store_path(1) }
      end

      fast_context "with available credits" do
        setup do
          @user.wishes << @lesson
          assert @user.on_wish_list?(@lesson)
          @user.credits.create!(:price => 0.99)
          assert_equal 1, @user.available_credits.size
          @credit = @user.available_credits.first
          assert !@user.owns_lesson?(@lesson)
          post :create, :id => @lesson
          @credit = Credit.find(@credit)
          assert_not_nil @credit.lesson
        end

        should "have decremented available credits" do
          assert @user.owns_lesson?(@lesson)
          assert_equal @credit.lesson.id, @lesson.id
          assert @user.available_credits.empty?
        end
        should "does not wish for the lesson" do
          assert !@user.on_wish_list?(@lesson)
        end
        should_assign_to :lesson
        should_not_set_the_flash
        should_redirect_to("watch lesson screen") { lesson_path(@lesson) }
      end
    end
  end
end
