require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class CategoryTest < ActiveSupport::TestCase
  fast_context "given an existing record" do
    setup do
      @category1 = Factory.create(:category)
      @category2 = Factory.create(:category)
    end
    subject { @category1 }

    should_belong_to :parent_category
    should_have_many :exploded_categories, :base_exploded_categories
    should_have_many :ancestor_categories, :early_ancestor_categories
    should_have_many :child_categories, :lessons
    should_have_many :groups
    should_validate_presence_of :name
    should_validate_uniqueness_of :name
    should_validate_numericality_of :sort_value, :level

    fast_context "testing list method" do
      setup { @categories = Category.list 1, 10 }
      subject { @categories }

      should "retrieve a value" do
        assert_equal 4, @categories.size
        assert @categories.include?(@category1)
        assert @categories.include?(@category1.parent_category)
      end
    end

    fast_context "testing can_delete?" do
      should "check can delete" do
        assert @category1.can_delete?
        assert !@category1.parent_category.can_delete?
      end

      context "with a lesson defined" do
        setup do
          Category.explode
          assert @category1.lessons.empty?
          @lesson = Factory.create(:lesson, :category => @category1)
          @lesson.update_attribute :status, LESSON_STATUS_READY
          @category1 = Category.find(@category1.id)
          assert_equal @category1, @lesson.category
          assert !@category1.lessons.empty?
        end

        should "calculate lesson count" do
          assert_equal 1, @category1.lesson_count
          assert_equal 0, @category2.lesson_count
        end

        fast_context "and a group defined" do
          setup { @group = Factory.create(:group, :category => @category1) }

          should "calculate group count" do
            assert_equal 1, @category1.group_count
            assert_equal 0, @category2.group_count
          end
        end

        should "not be able to delete" do
          assert !@category1.can_delete?
          assert !@category1.parent_category.can_delete?
        end
      end
    end

    fast_context "and a second sub category" do
      setup do
        @category1a = Factory.create(:category, :parent_category => @category1.parent_category)
        assert_equal 5, Category.count
        assert_equal 2, @category1.parent_category.child_categories.size
      end

      fast_context "testing exploding" do
        setup do
          Category.explode
          @exploded_categories = ExplodedCategory.all
          @ancestor_categories = AncestorCategory.all
        end

        should "have explode values" do
          assert_equal 8, @exploded_categories.size
          assert_equal 3, @ancestor_categories.size
        end
      end
    end
  end
end