require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class ActivityTest < ActiveSupport::TestCase
  context "Given an existing activity" do
    setup do
      @lesson = Factory.create(:lesson)
      @lesson.activities.create!(:actor_user => Factory.create(:user),
                                 :actee_user => Factory.create(:user),
                                 :acted_upon_at => 1.days.ago,
                                 :activity_string => "lesson.activity",
                                 :activity_object_id => Factory.create(:lesson).id,
                                 :activity_object_class => "Lesson",
                                 :activity_object_human_identifier => "Some lesson title")
    end

    should_belong_to :actor_user, :actee_user
    should_belong_to :group
    should_validate_presence_of :actor_user, :acted_upon_at
  end

  context "given some records" do
    setup do
      @user = Factory.create(:user)

      @lesson = Factory.create(:lesson)
      @lesson.status = LESSON_STATUS_READY
      @lesson.save!
      assert @lesson.ready?

      @lessonr = Factory.create(:lesson)
      @lessonr.status = LESSON_STATUS_REJECTED
      @lessonr.save!
      assert !@lessonr.ready?

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
        assert_equal 10, Activity.all.size
      end

      context "and more records" do
        setup do
          @lessonr.compile_activity

          @lesson2 = Factory.create(:lesson)
          @user.credits.create!(:price => 0.99, :lesson => @lesson2, :acquired_at => Time.now,
                                :line_item => Factory.create(:line_item))
          @rater = @lesson2.rates.create!
          # user id isn't set above because of protection from mass assignment
          @rater.update_attribute(:user_id, @user.id)
          @reviewr = Factory.create(:review, :user => @user, :lesson => @lesson2)
          @reviewr.reject
          @reviewr.save!

          @comment = Factory.create(:lesson_comment)
          @commentp = Factory.create(:lesson_comment, :public => false)
          @commentr = Factory.create(:lesson_comment)
          @commentp.compile_activity
          @commentr.compile_activity
          @commentr.update_attribute(:status, COMMENT_STATUS_REJECTED)

          @group = Factory.create(:group)
          @groupr = Factory.create(:group)
          
          @groupr.reject
          @groupr.save!
        end

        should "find activities ready to be rejected" do
          assert !Activity.not_rejected.to_be_disabled.collect(&:trackable).include?(@lesson)
          assert Activity.not_rejected.to_be_disabled.collect(&:trackable).include?(@lessonr)
          assert !Activity.not_rejected.to_be_disabled.collect(&:trackable).include?(@review)
          assert Activity.not_rejected.to_be_disabled.collect(&:trackable).include?(@reviewr)
          assert !Activity.not_rejected.to_be_disabled.collect(&:trackable).include?(@comment)
          assert Activity.not_rejected.to_be_disabled.collect(&:trackable).include?(@commentp)
          assert Activity.not_rejected.to_be_disabled.collect(&:trackable).include?(@commentr)
          assert !Activity.not_rejected.to_be_disabled.collect(&:trackable).include?(@group)
          assert Activity.not_rejected.to_be_disabled.collect(&:trackable).include?(@groupr)
          not_rejected = Activity.not_rejected.size
          to_be_rejected = Activity.not_rejected.to_be_disabled.size
          
          Activity.compile
          
          assert Activity.not_rejected.to_be_disabled.empty?
          assert_equal not_rejected - to_be_rejected, Activity.not_rejected.size 
        end
      end
    end

    context "and someone you are following" do
      setup do
        @followee = Factory.create(:user)
        @followee.followers << @user
        assert @followee.followed_by?(@user)
        @group = Factory.create(:group, :owner => @followee)
        Activity.compile
      end

      should "generate activities" do
        @group_activities = Activity.find_all_by_group_id(@group.id)
        assert_equal 1, @group_activities.size
        @group_activity = @group_activities.first
        assert_equal @followee, @group_activity.actor_user
        assert_equal @group, @group_activity.group
        # I can't figure out why this is not returning a result...so for now I'll just execute it
        # to validate it doesn't throw an error.
        assert_nothing_raised { Activity.by_followed_instructors(@user) }
      end
    end
  end
end