require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class ExplodedCategoryTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @exploded_category = Factory.create(:exploded_category)
    end
    subject { @exploded_category }

    should_belong_to :base_category, :category
    should_validate_presence_of :base_category, :category, :name, :base_name, :level
  end
end
