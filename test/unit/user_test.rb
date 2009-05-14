require 'test_helper'

class UserTest < ActiveSupport::TestCase
  CHARSET = "utf-8"

  context "given an existing record" do
    setup { @user = Factory.create(:user) }

    should_validate_uniqueness_of    :email
    should_validate_uniqueness_of    :nickname
    should_validate_presence_of      :email, :last_name, :nickname
    should_validate_numericality_of  :login_count, :failed_login_count
#    should_not_allow_values_for      :email, "blahhhh", "bbbb lah"
    should_allow_values_for          :email, "apple@b.com", "asdf@asdf.com"
    should_allow_values_for          :nickname, "spob", "big boy", "  test "
    should_ensure_length_in_range    :email, (6..100)    
    should_ensure_length_in_range    :last_name, (0..40)
    should_ensure_length_in_range    :first_name, (0..40)
    should_ensure_length_in_range    :nickname, (0..25)

    context "and a couple more records" do
      setup do
        # and let's create a couple more
        Factory.create(:user)
        Factory.create(:user)
      end

      should "return user records" do
        assert_equal 3, User.list(1).size
      end
    end

    context "and password reset requests" do
      setup do
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.deliveries = []

        @expected = TMail::Mail.new
        @expected.set_content_type "text", "plain", { "charset" => CHARSET }
      end

      should "generate email" do
        response = @user.deliver_password_reset_instructions!

        assert_equal 'Your password has been reset', response.subject
        assert_match /A request to reset your password has been made/, response.body
#        assert_match /Dear #{user.full_name},/, response.body
        assert_equal @user.email, response.to[0]
      end
    end
  end
end
