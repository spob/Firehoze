require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class InstructorFollowsControllerTest < ActionController::TestCase
  fast_context "when logged on" do
    setup do
      activate_authlogic
      @user = Factory(:user)
      UserSession.create @user

      @instructor = Factory(:user)
    end

    fast_context "on POST to :create" do
      setup do
        assert @instructor.followers.empty?
        post :create, :id => @instructor
        @instructor = User.find(@instructor.id)
      end

      should_assign_to :instructor
      should_respond_with :redirect
      should_set_the_flash_to /not an instructor/
      should "not create a follower" do
        assert @instructor.followers.empty?
      end
    end

    fast_context "with an instructor defined" do
      setup do
        @instructor.address1 = "135 Larch Row"
        @instructor.city = "Wenham"
        @instructor.state = "MA"
        @instructor.postal_code = "01984"
        @instructor.country = "US"
        @instructor.verified_address_on = Time.now
        @instructor.author_agreement_accepted_on = Time.now
        @instructor.payment_level = Factory.create(:payment_level)
        @instructor.save!
        assert @instructor.verified_instructor?
      end

      fast_context "on POST to :create" do
        setup do
          assert @instructor.followers.empty?
          post :create, :id => @instructor
          @instructor = User.find(@instructor.id)
        end

        should_assign_to :instructor
        should_respond_with :redirect
        should_set_the_flash_to /being followed/
        should "create a follower" do
          assert_equal 1, @instructor.followers.size
        end
      end
    end

    fast_context "when following an instructor" do
      setup do
        @instructor.followers << @user
      end

      fast_context "on DELETE to :destroy" do
        setup do
          assert @instructor.followers.include?(@user)
          delete :destroy, :id => @instructor
          @instructor = User.find(@instructor.id)
        end

        should_assign_to :instructor
        should_respond_with :redirect
        should_set_the_flash_to /no longer being followed/
        should "delete the follower" do
          assert @instructor.followers.empty?
        end
      end
    end
  end
end