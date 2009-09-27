require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class CategoryTest < ActiveSupport::TestCase
  fast_context "given an existing record" do
    setup { @category = Factory.create(:category) }
    subject { @category }

    should_belong_to :parent_category
    should_have_many :child_categories
    should_validate_presence_of :name
    should_validate_uniqueness_of :name
    should_validate_numericality_of  :sort_value

    fast_context "testing list method" do
      setup { @categories = Category.list 1, 10 }
      subject { @categories }

      should "retrieve a value" do
        assert_equal 2, @categories.size
        assert @categories.include?(@category)
        assert @categories.include?(@category.parent_category)
      end
    end

    fast_context "testing can_delete?" do
      should "check can delete" do
        assert @category.can_delete?
        assert !@category.parent_category.can_delete?
      end
    end
  end
end
