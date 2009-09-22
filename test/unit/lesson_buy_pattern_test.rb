require File.dirname(__FILE__) + '/../test_helper'
require 'fast_context'

class LessonBuyPatternTest < ActiveSupport::TestCase
  fast_context "given an existing record" do
    setup { @lesson_buy_pattern = Factory.create(:lesson_buy_pattern) }

    should_belong_to :lesson, :purchased_lesson
    should_validate_presence_of :lesson, :purchased_lesson, :counter
  end

  fast_context "given multiple visit records" do
    setup do
      @lesson = Factory.create(:lesson)
      @visit1 = Factory.create(:lesson_visit)
      @visit2 = Factory.create(:lesson_visit)
      @visit3 = Factory.create(:lesson_visit, :owned => true)
      @visit4 = Factory.create(:lesson_visit)
      @visit5 = Factory.create(:lesson_visit, :purchased_this_visit => true)
      assert_equal @visit5.session_id, @visit1.session_id
      assert !@visit1.purchased_this_visit
      assert @visit5.purchased_this_visit

      LessonBuyPattern.rollup_buy_patterns
    end

    should "calculate rollups" do
      @pattern1 = LessonBuyPattern.by_purchased_lesson(@visit5.lesson.id).by_lesson(@visit1.lesson.id).first
      assert !@pattern1.nil?
      assert_equal 1, @pattern1.counter
      @pattern2 = LessonBuyPattern.by_purchased_lesson(@visit5.lesson.id).by_lesson(@visit2.lesson.id).first
      assert !@pattern2.nil?
      assert_equal 1, @pattern2.counter
      @pattern3 = LessonBuyPattern.by_purchased_lesson(@visit5.lesson.id).by_lesson(@visit3.lesson.id).first
      assert @pattern3.nil?
      @pattern4 = LessonBuyPattern.by_purchased_lesson(@visit5.lesson.id).by_lesson(@visit4.lesson.id).first
      assert !@pattern4.nil?
      assert_equal 1, @pattern4.counter
      @pattern5 = LessonBuyPattern.by_purchased_lesson(@visit5.lesson.id).by_lesson(@visit5.lesson.id).first
      assert !@pattern5.nil?
      assert_equal 1, @pattern5.counter
    end

    fast_context "with existing buy pattern records" do
      setup do
        @visit6 = Factory.create(:lesson_visit, :lesson => @visit4.lesson, :session_id => '2342')
        @visit7 = Factory.create(:lesson_visit, :lesson => @visit5.lesson, :session_id => '2342',
                                 :purchased_this_visit => true)
        LessonBuyPattern.rollup_buy_patterns
      end

      should "update buy pattern counter" do
        @pattern6 = LessonBuyPattern.by_purchased_lesson(@visit7.lesson.id).by_lesson(@visit6.lesson.id).first
        assert !@pattern6.nil?
        assert_equal 2, @pattern6.counter
      end
    end
  end
end
