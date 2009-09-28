require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class AncestorCategoryTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup do
      @ancestor_category = Factory.create(:ancestor_category)
    end
    subject { @ancestor_category }

    should_belong_to :ancestor_category, :category
    should_validate_presence_of :ancestor_category, :category, :name, :ancestor_name, :generation
  end
end
