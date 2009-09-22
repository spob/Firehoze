require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class FlagTest < ActiveSupport::TestCase
  fast_context "given an existing record" do
    setup do
      @lesson = Factory.create(:lesson)
      @lesson.flags.create!(:status => FLAG_STATUS_PENDING, :reason_type => "Smut", :comments => "Some comments",
                            :user => Factory.create(:user))
      assert !@lesson.nil?
      assert !Flag.all.empty?
      assert !Flag.pending.empty?
    end

    fast_context "when calling user.has_flaggable?" do
      should "find flaggable" do
        assert !@lesson.flags.first .nil?
        assert @lesson.flags.first.user.has_flagged?(@lesson)
        assert !@lesson.flags.first.user.has_flagged?(Factory.create(:lesson))
      end
    end

    fast_context "and invoking the by_flaggable scope" do
      should "return rows appropriately" do
        assert !@lesson.flags.first.user.flaggings.empty?
        assert !@lesson.flags.first.user.flaggings.by_flaggable_type(Lesson).empty?
        assert_equal @lesson.flags.first, @lesson.flags.first.user.flaggings.by_flaggable_type(Lesson).first
        assert @lesson.flags.first.user.flaggings.by_flaggable_type(User).empty?
        assert @lesson.flags.first.user.flaggings.by_flaggable_type(Comment).empty?
        assert @lesson.flags.first.user.flaggings.by_flaggable_type(Review).empty?
      end
    end

    should_belong_to :user
    #should_belong_to :moderator_user
    should_validate_presence_of :user, :reason_type, :comments
    should_allow_values_for     :status, FLAG_STATUS_PENDING, FLAG_STATUS_RESOLVED,
                                FLAG_STATUS_RESOLVED_MANUALLY, FLAG_STATUS_REJECTED
    should_not_allow_mass_assignment_of :response, :status
    #should_not_allow_values_for :status, "blah"

    should "set the friendly name" do
      assert_equal @lesson.title, @lesson.flags.first.friendly_flagger_name
    end

    should "return one pending flag" do
      assert_equal 1, Flag.pending.size
    end
  end
end
