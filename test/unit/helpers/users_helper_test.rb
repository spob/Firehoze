require File.dirname(__FILE__) + '/../../test_helper'

class UsersHelperTest < ActionView::TestCase
  tests UsersHelper

  context "possessive_helper" do
    should "Form possessive" do
      assert_equal "dog's", possessive_helper("dog")
      assert_equal "dogs'", possessive_helper("dogs")
    end
  end

  context "given user a and user b" do
    setup do
      @instructor = Factory.create(:user)
      @user = Factory.create(:user)
    end

    should "not ask to follow" do
      assert follow_link(@instructor, @user).nil?
      assert follow_link(@instructor, nil).nil?
    end

    context "and user a is an instructor" do
      setup do
        set_instructor(@instructor)
        assert @instructor.verified_instructor?
      end

      should "ask to follow" do
        assert /Follow this instructor/.match(follow_link(@instructor, @user))
      end

      context "and user b is following user a" do
        setup { @instructor.followers << @user }

        should "ask to stop following" do
          assert !@user.nil?
          assert /Stop Following/.match(follow_link(@instructor, @user))
        end
      end
    end
  end

  context "given a user" do
    setup { @user = Factory.create(:user) }

    context "with a bio" do
      setup { @user.update_attribute(:bio, "hello") }

      should "return a bio" do
        assert "hello", show_bio
      end

      context "that was rejected" do
        setup { @user.update_attribute(:rejected_bio, true)}

        should "return a reject message" do
          assert /flagged/.match(show_bio)
        end
      end
    end

    context "with a blank bio" do

      should "not return a bio" do
        assert show_bio.nil?
      end
    end
  end

  private

  def set_instructor user
    user.author_agreement_accepted_on = Time.now
    user.payment_level = Factory.create(:payment_level)
    user.address1 = "xxx"
    user.city = "yyy"
    user.state = "XXX"
    user.postal_code = "99999"
    user.country = "US"
    user.verified_address_on = Time.now
    user.save!
    user = User.find(user)
  end

  # to prevent undefined method when forms are involved
  def protect_against_forgery?
    false
  end
end
