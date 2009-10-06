require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class ActivityTest < ActiveSupport::TestCase
  context "Given an existing activity" do
    setup do
      @lesson = Factory.create(:lesson)
      @lesson.activities.create!(:actor_user => Factory.create(:user),
                                 :actee_user => Factory.create(:user),
                                 :acted_upon_at => 1.days.ago)
    end

    should_belong_to :actor_user, :actee_user
    should_validate_presence_of :actor_user, :acted_upon_at
  end

  context "given some records" do
    setup do
      @user = Factory.create(:user)
      
      @lesson = Factory.create(:lesson)
      @lesson.status = LESSON_STATUS_READY
      @lesson.save!
      assert @lesson.ready?
      
      @user.credits.create!(:price => 0.99, :lesson => @lesson, :acquired_at => Time.now,
                            :line_item => Factory.create(:line_item))

      @comment = Factory.create(:lesson_comment)

      @rate = @lesson.rates.create!
      # user id isn't set above because of protection from mass assignment
      @rate.update_attribute(:user_id, @user.id)
      assert_equal @lesson, @lesson.rates.first.rateable
      assert_equal @user, @lesson.rates.first.user
      @review = Factory.create(:review, :user => @user, :lesson => @lesson)
      assert @user.owns_lesson?(@lesson)
    end

    context "compile activities" do
      setup { Activity.compile }

      should "populate activities" do
        assert !Activity.all.empty?
        assert_equal 3, Activity.all.size
      end
    end
  end
end
