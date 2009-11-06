require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class GroupLessonTest < ActiveSupport::TestCase
  fast_context "given an group lesson" do
    setup { @group_lesson = Factory.create(:group_lesson) }
    subject { @group_lesson }

    should_belong_to :user
    should_belong_to :lesson
    should_belong_to :group
    should_have_many :activities
    should_validate_presence_of :user, :lesson, :group

    fast_context "compile_activity" do
      setup do
        @group_lesson2 = Factory.create(:group_lesson, :active => false)
        assert @group_lesson.activities.empty?
        assert @group_lesson2.activities.empty?
        Activity.compile
        @group_lesson = GroupLesson.find(@group_lesson.id)
        @group_lesson2 = GroupLesson.find(@group_lesson2.id)
      end

      should "generate activity records" do
        assert_equal @group_lesson, @group_lesson.activities.first.trackable
        assert @group_lesson2.activities.empty?
      end
    end
  end
end
