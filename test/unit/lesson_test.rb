require 'test_helper'

class LessonTest < ActiveSupport::TestCase

  context "given an existing lesson" do
    setup do
      @lesson = Factory.create(:lesson)
    end

    should_validate_presence_of      :title, :instructor, :video_file_name
    should_allow_values_for          :title, "blah blah blah"
    should_ensure_length_in_range    :title, (0..50)
    should_have_attached_file        :video
    should_have_many                 :reviews, :lesson_state_changes

    should "have a state change record" do
      assert_equal 1, @lesson.lesson_state_changes.size
      assert_nil @lesson.lesson_state_changes.first.from_state
      assert_equal "pending", @lesson.lesson_state_changes.first.to_state
      assert_equal "Lesson created", @lesson.lesson_state_changes.first.message
    end

    context "and trigger a conversion" do
      setup { @job = @lesson.trigger_conversion }

      should "create a job" do
        assert_equal "ConvertVideo", @job.name
      end
    end

    context "that changed state" do
      setup { @lesson.change_state('done', 'test msg') }

      should "have another state change record" do
        assert_equal 2, @lesson.lesson_state_changes.size
        assert_equal "pending", @lesson.lesson_state_changes.last.from_state
        assert_equal "done", @lesson.lesson_state_changes.last.to_state
        assert_equal "test msg", @lesson.lesson_state_changes.last.message
      end
    end

    context "and a couple more records" do
      setup do
        # and let's create a couple more
        @lesson2 = Factory.create(:lesson)
        @lesson3 = Factory.create(:lesson)
        @lesson.update_attribute(:state, LESSON_STATE_PENDING)  
        @lesson2.update_attribute(:state, LESSON_STATE_READY)
        @lesson3.update_attribute(:state, LESSON_STATE_READY)
      end

      should "not show that it has been reviewed" do
        assert !@lesson.reviewed_by?(Factory.create(:user))
      end

      should "return less records" do
        assert_equal 2, Lesson.list(1).size
        assert_equal 3, Lesson.list(1, true).size
      end
    end

    context "and lessons by two different authors" do
      setup do
        @user1 = Factory.create(:user)
        @user2 = Factory.create(:user)
        @user3 = Factory.create(:user)
        @user3.is_admin
        @lesson1 =  Factory.create(:lesson, :instructor => @user1)
        @lesson2 =  Factory.create(:lesson, :instructor => @user2)
      end

      should "allow author to edit" do
        # author can edit their lessons
        assert @lesson1.can_edit?(@user1)
        assert !@lesson1.can_edit?(@user2)
        assert @lesson2.can_edit?(@user2)
        assert !@lesson2.can_edit?(@user1)

        # Admin should be able to edit both
        assert @lesson2.can_edit?(@user3)
        assert @lesson2.can_edit?(@user3)
      end
    end
  end
end