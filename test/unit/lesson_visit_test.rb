require 'test_helper'

class LessonVisitTest < ActiveSupport::TestCase
  context "given an existing record" do
    setup { @lesson_visit = Factory.create(:lesson_visit) }

    should_belong_to :user
    should_belong_to :lesson
    should_validate_presence_of :lesson, :session_id

    context "retrieving using named scope" do
      should "retrieve a lesson visit" do
        assert_equal 1, LessonVisit.by_lesson_and_session(@lesson_visit.lesson.id,
                                                          @lesson_visit.session_id).size
      end
    end
  end

  context "and exercising touch" do
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