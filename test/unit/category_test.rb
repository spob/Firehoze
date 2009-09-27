require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class CategoryTest < ActiveSupport::TestCase
  fast_context "given an existing record" do
    setup { @category = Factory.create(:category) }
    subject { @category }

    should_belong_to :parent_category
    should_have_many :child_categories
    should_validate_presence_of      :name
    should_validate_uniqueness_of    :name
  end
end
