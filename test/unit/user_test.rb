require 'test_helper'

class UserTest < ActiveSupport::TestCase
  CHARSET = "utf-8"

  context "given an existing record" do
    setup { @user = Factory.create(:user) }

    should_validate_uniqueness_of    :email
    should_validate_uniqueness_of    :login
    should_validate_presence_of      :email, :last_name, :login, :language
    should_validate_numericality_of  :login_count, :failed_login_count
    
    # Apparently should not allow values for only works if you pass the error message you expect
    # to see...though this is not clear in the shoulda documentation.
    should_not_allow_values_for      :email, "blahhhh", "bbbb lah",
                                     :message => /should look like an email address/
    should_allow_values_for          :email, "apple@b.com", "asdf@asdf.com"
    should_allow_values_for          :login, "spob", "big boy", "  test "
    
    # Apparently should not allow values for only works if you pass the error message you expect
    # to see...though this is not clear in the shoulda documentation.
    should_not_allow_values_for      :login, "1234567890123456789012345678", :message => I18n.translate('activerecord.errors.messages.too_long', :count => 25)
    should_ensure_length_in_range    :email, (6..100)    
    should_ensure_length_in_range    :last_name, (0..40)
    should_ensure_length_in_range    :first_name, (0..40)
    should_ensure_length_in_range    :login, (0..25)
    should_have_many                 :credits
    should_have_many                 :reviews
    should_have_many                 :user_logons
    should_have_many                 :helpfuls

    context "and a couple more records" do
      setup do
        # and let's create a couple more
        Factory.create(:user)
        Factory.create(:user)
      end

      should "return user records" do
        assert_equal 3, User.list(1).size
      end
       
      should "find 3 records" do
        user_list = User.active
        assert_equal 3, user_list.size
      end
      
      should "delete all records" do
        user_list = User.find(:all)
        user_list.each do |usr|
            usr.destroy
        end
        user_list = User.find(:all)
        assert_equal 0, user_list.size
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
  
  context "More user testing" do
    setup do 
      @user = Factory.create(:user) 
      @expectedLang =  [['English', 'en'], ['Wookie', 'wk'] ]      
    end
    
    should "support English and Wookie" do
      l = User.supported_languages
      assert_equal @expectedLang, l
    end
    
    should "return fullname as first plus last" do
      fn = @user.first_name
      ln = @user.last_name
      assert_equal @user.full_name, "#{fn} #{ln}"
    end


    should "return fullname as just last" do
      @user.first_name = nil
      ln = @user.last_name
      
      assert_equal @user.full_name, "#{ln}"

      @user.first_name =""
      assert_equal @user.full_name, "#{ln}"
    end
  end
end
