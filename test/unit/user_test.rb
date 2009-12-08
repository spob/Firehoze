require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class UserTest < ActiveSupport::TestCase
  CHARSET = "utf-8"

  fast_context "given an existing record" do
    setup { @user = Factory.create(:user) }
    subject { @user }


    should_validate_uniqueness_of :email
    should_validate_uniqueness_of :login
    should_validate_presence_of :last_name, :login, :language, :instructor_status
    should_validate_presence_of :user_agreement_accepted_on, :message => /must be selected/
    should_validate_numericality_of :login_count, :failed_login_count
    should_not_allow_mass_assignment_of :email, :login, :rejected_bio, :instructor_status, :address1, :address2,
                                        :city, :state, :postal_code, :country, :author_agreement_accepted_on,
                                        :withold_taxes, :payment_level_id, :user_logons, :credits, :gift_certificates, :orders, :lesson_visits,
                                        :flags, :flaggings, :lesson_comments, :instructed_lessons, :payments, :reviews, :helpfuls, :wishes

    # Apparently should not allow values for only works if you pass the error message you expect
    # to see...though this is not clear in the shoulda documentation.
    should_not_allow_values_for :email, "blahhhh", "bbbb lah",
                                :message => /should look like an email address/
    should_allow_values_for :email, "apple@b.com", "asdf@asdf.com"
    should_allow_values_for :login, "spob", "big boy", "  test "

    # Apparently should not allow values for only works if you pass the error message you expect
    # to see...though this is not clear in the shoulda documentation.
    should_not_allow_values_for :login, "1234567890123456789012345678", :message => I18n.translate('activerecord.errors.messages.too_long', :count => 25)
    should_ensure_length_in_range :email, (6..100)
    should_ensure_length_in_range :last_name, (0..40)
    should_ensure_length_in_range :first_name, (0..40)
    should_ensure_length_in_range :login, (0..25)
    should_have_many :credits
    should_have_many :gift_certificates
    should_have_many :reviews
    should_have_many :orders
    should_have_many :flags
    should_have_many :lessons
    should_have_many :lesson_ids
    should_have_many :lesson_comments
    should_have_many :flaggings
    should_have_many :user_logons
    should_have_many :group_members
    should_have_many :groups
    should_have_many :group_ids
    should_have_many :moderated_groups
    should_have_many :member_groups
    should_have_many :helpfuls
    should_have_many :lesson_visits
    should_have_many :visited_lessons
    should_have_many :instructed_lessons
    should_have_many :instructed_lesson_ids
    should_have_many :payments
    should_have_many :activities
    should_belong_to :payment_level
    should_have_and_belong_to_many :wishes
    should_have_and_belong_to_many :followers
    should_have_and_belong_to_many :followed_instructors

    fast_context "testing lookup by address and email" do
      should "find by address or email" do
        assert User.find_by_login_or_email(@user.login, "blah")
        assert User.find_by_login_or_email("xxx", @user.email)
        assert_nil User.find_by_login_or_email("xxx", "yyy")
      end
    end

    fast_context "when rejecting" do
      setup do
        assert !@user.rejected_bio
        @user.reject
        @user.save
      end

      should "be rejected" do
        assert @user.rejected_bio
      end
    end

    fast_context "and an item on the wish list" do
      setup do
        @lesson = Factory.create(:lesson)
        @lesson2 = Factory.create(:lesson)
        @user.wishes << @lesson
      end

      should "find lesson on wish list" do
        assert @user.on_wish_list?(@lesson)
        assert !@user.on_wish_list?(@lesson2)
      end
    end

    fast_context "and a couple more records" do
      setup do
        # and let's create a couple more
        @user2 = Factory.create(:user)
        @user3 = Factory.create(:user)
        @user3.has_role 'admin'
      end

      should "return one admin record" do
        admins = User.admins
        assert_equal 1, admins.size
        assert_equal @user3, admins.first
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

    fast_context "and password reset requests" do
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

    should "return fullname as first plus last" do
      fn = @user.first_name
      ln = @user.last_name
      assert_equal @user.full_name, "#{fn} #{ln}"
      assert !@user.address_provided?
    end

    fast_context "with address specified" do
      setup do
        @user.address1 = "135 Larch Row"
        @user.city = "Wenham"
        @user.state = "MA"
        @user.postal_code = "01984"
        @user.country = "US"
        assert !@user.verified_instructor?
      end

      should "validate address" do
        assert @user.address_provided?
      end

      fast_context "while testing if an instructor" do
        setup do
          @user.verified_address_on = Time.now
          assert !@user.verified_instructor?
          @user.author_agreement_accepted_on = Time.now
          assert !@user.verified_instructor?
          @user.payment_level = Factory.create(:payment_level)
        end

        should "be an instructor" do
          assert @user.verified_instructor?
        end
      end
    end

    should "return fullname as just last" do
      @user.first_name = nil
      ln = @user.last_name

      assert_equal @user.full_name, "#{ln}"

      @user.first_name =""
      assert_equal @user.full_name, "#{ln}"
    end

    fast_context "and several expected languages" do
      setup { @expected_lang = [['English', 'en'] ] }

      should "support English and Wookie" do
        l = User.supported_languages
        assert_equal @expected_lang, l
      end
    end

    fast_context "and a lesson" do
      setup { @lesson = Factory.create(:lesson) }

      should "not have the user owning that lesson" do
        assert !@user.owns_lesson?(@lesson)
      end

      fast_context "which the user owns" do
        setup do
          @user.credits.create(:price => 0.99, :acquired_at => 2.days.ago)
          @credit = @user.credits.first
          @credit.lesson = @lesson
          @credit.save!
        end

        should "have the user owning that lesson" do
          assert @user.owns_lesson?(@lesson)
          assert !@user.lessons.empty?
          assert @user.lessons.include?(@lesson)
        end
      end
    end
  end

  fast_context "Given lesson visits" do
    setup { @lesson_visit = Factory.create(:lesson_visit) }

    should "retrieve lessons and visits" do
      assert_equal 1, @lesson_visit.user.lesson_visits.size
      assert_equal 1, @lesson_visit.user.visited_lessons.size
    end
  end
end
