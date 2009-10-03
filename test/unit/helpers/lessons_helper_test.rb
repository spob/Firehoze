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
  end
end
