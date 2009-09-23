require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class LessonVisitTest < ActiveSupport::TestCase
  fast_context "given an existing record" do
    setup { @lesson_visit = Factory.create(:lesson_visit, :purchased_this_visit => true) }
    subject { @lesson_visit }

    should_belong_to :user
    should_belong_to :lesson
    should_validate_presence_of :lesson, :session_id

    fast_context "retrieving using named scope" do
      should "retrieve a lesson visit" do
        assert_equal 1, LessonVisit.by_lesson(@lesson_visit.lesson.id).by_session(@lesson_visit.session_id).size
        assert_equal 1, LessonVisit.by_user(@lesson_visit.user.id).size
        assert_equal 1, LessonVisit.latest.size
        assert_equal 1, LessonVisit.by_not_session("xxx").size
      end

      fast_context "searching uncompiled purchases" do
        setup { @lesson_visit2 = Factory.create(:lesson_visit) }

        should "retrieve a lesson visit" do
          assert_equal 2, LessonVisit.all.size
          assert_equal 1, LessonVisit.uncompiled_lesson_purchases.size
        end
      end
    end
  end

  fast_context "while exercising touch" do
    setup do
      assert LessonVisit.all.empty?
      LessonVisit.touch(Factory.create(:lesson),
                        Factory.create(:user),
                        "sadfasafsdf")
    end

    should "create a record" do

    end
  end
end