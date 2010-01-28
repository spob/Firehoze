require File.dirname(__FILE__) + '/../../test_helper'
require 'fast_context'

class LessonsHelperTest < ActionView::TestCase

  fast_context "given an existing record" do
    setup { @category = Factory.create(:category) }

    fast_context "testing bread crumb" do
      setup do
        @category3 = Factory.create(:category, :parent_category => @category)
        Category.explode
      end

      should "calc breadcrumb" do
        assert_equal @category.parent_category.name, bread_crumb(@category.parent_category)
        assert_equal "#{link_to(@category.parent_category.name, category_path(@category.parent_category))} > #{@category.name}",
                     bread_crumb(@category)
        assert_equal "#{link_to(@category.parent_category.name, category_path(@category.parent_category))} > #{link_to(@category.name, category_path(@category))} > #{@category3.name}",
                     bread_crumb(@category3)
      end
    end

    fast_context "testing remaining free credits text" do
      setup do
        @sku = Factory.create(:credit_sku, :sku => FREE_CREDIT_SKU)
        @lesson = Factory.create(:lesson, :initial_free_download_count => 5)
        @lesson.reload
        @lesson.update_attribute(:status, LESSON_STATUS_READY)
        assert_equal 5, @lesson.free_credits.available.size
      end

      should "show owned_it text" do
        assert_match /5 Free Views Remaining/, free_remaining_text(@lesson)
      end
    end

    fast_context "a ready lesson" do
      setup do
        @user = Factory.create(:user)
        @lesson = Factory.create(:lesson)
        @lesson.update_attribute(:status, LESSON_STATUS_READY)
      end

      fast_context "user is an admin" do
        setup do
          @user.has_role('admin')
        end

        should "test link_to_add_attachment" do
          assert_nil link_to_add_attachment(@lesson, Factory.create(:user))
          assert_nil link_to_add_attachment(@lesson, nil)
          assert_match /Add Attachment/, link_to_add_attachment(@lesson, @user)
        end
      end

      fast_context "user is an moderator" do
        setup do
          @user.has_role('moderator')
        end

        should "test link_to_add_attachment" do
          assert_nil link_to_unreject(@lesson, Factory.create(:user))
          assert_nil link_to_unreject(@lesson, nil)
          assert_nil link_to_unreject(@lesson, @user)
        end

        fast_context "and lesson is rejected" do
          setup do
            @lesson.update_attribute(:status, LESSON_STATUS_REJECTED)
          end

          should "test link_to_add_attachment" do
            assert_match /unreject/, link_to_unreject(@lesson, @user)
          end
        end
      end

      fast_context "user owns it" do
        setup do
          @user.credits.create!(:price => 0.99, :lesson => @lesson)
          assert @user.owns_lesson?(@lesson)
        end

        should "test owned_it" do
          assert_nil owned_it_phrase(@lesson, Factory.create(:user))
          assert_nil owned_it_phrase(@lesson, nil)
          assert_match /own/, owned_it_phrase(@lesson, @user)
        end
      end
    end
  end
end