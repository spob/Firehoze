require 'test_helper'

class UserTest < ActiveSupport::TestCase

  context "given an existing record" do
    setup do
      Factory.create(:user)
    end

    should_validate_uniqueness_of    :email
    should_validate_presence_of      :email
    should_validate_numericality_of  :login_count, :failed_login_count
#    should_not_allow_values_for      :email, "blahhhh", "bbbb lah"
    should_allow_values_for          :email, "apple@b.com", "asdf@asdf.com"
    should_ensure_length_in_range    :email, (6..100)
  end

  # Replace this with your real tests.
  test "the truth" do
#    assert_not_nil  Factory(:user).nil?
  end
end
