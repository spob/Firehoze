require File.dirname(__FILE__) + '/../../test_helper'

class UsersHelperTest < ActionView::TestCase
  context "possessive_helper" do

    should "Form possessive" do
      assert_equal "dog's", possessive_helper("dog")
      assert_equal "dogs'", possessive_helper("dogs")
    end
  end
end
